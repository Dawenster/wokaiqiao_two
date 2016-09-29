class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_attached_file :picture,
                    styles: { medium: "300x300#", thumb: "100x100#" },
                    default_url: "https://s3-us-west-2.amazonaws.com/wokaiqiao/users/missing-user.png",
                    storage: :s3,
                    s3_credentials: Proc.new{|a| a.instance.s3_credentials },
                    s3_protocol: :https

  validates_attachment_content_type :picture, content_type: /\Aimage\/.*\Z/
  validates :name, :email, :agreed_to_policies, presence: true
  validates :rate_per_minute, :numericality => { :greater_than_or_equal_to => 0 }, :allow_nil => true

  before_save :ensure_auth_token

  scope :admin, -> {
    where(admin: true)
  }
  scope :experts, -> {
    where(expert: true)
  }

  has_many :calls
  has_many :calls_as_expert, class_name: Call, foreign_key: :expert_id
  has_many :cancellations_initiated, class_name: Call, foreign_key: :cancelled_by
  has_many :credits
  has_many :educations
  accepts_nested_attributes_for :educations, allow_destroy: true
  has_many :payments
  has_many :refunds
  has_many :payouts, class_name: Payout, foreign_key: :expert_id
  has_and_belongs_to_many :promotions, uniq: true
  has_and_belongs_to_many :tags, class_name: Tag, join_table: "experts_tags", foreign_key: "expert_id", uniq: true
  has_many :fake_comments

  EXPERT_SORT_CATEGORIES = [
    DOMESTIC       = "domestic",
    PRICE_UP       = "price-up",
    PRICE_DOWN     = "price-down",
    HIGHEST_RATING = "highest-rating",
    MOST_COMMENTS  = "most-comments"
  ]

  def s3_credentials
    {
      bucket: ENV['AWS_BUCKET'],
      access_key_id: ENV["AWS_ACCESS_KEY"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
    }
  end

  def list_education
    educations.map{|e|e.name_with_year}.join("，")
  end

  def all_calls
    calls.not_cancelled.order("scheduled_at DESC") + calls_as_expert.not_cancelled.order("scheduled_at DESC")
  end

  def all_completed_calls
    calls.completed.order("scheduled_at DESC") + calls_as_expert.completed.order("scheduled_at DESC")
  end

  def all_cancelled_calls
    calls.cancelled.order("scheduled_at DESC") + calls_as_expert.cancelled.order("scheduled_at DESC")
  end

  def need_to_action_on(call)
    self == call.person_to_action
  end

  def role_in(call)
    self == call.user ? Call::USER_ACCEPTOR_TEXT : Call::EXPERT_ACCEPTOR_TEXT
  end

  def is_user_in?(call)
    role_in(call) == Call::USER_ACCEPTOR_TEXT
  end

  def is_expert_in?(call)
    role_in(call) == Call::EXPERT_ACCEPTOR_TEXT
  end

  # USERS ONLY ==============================================================

  def net_credits
    net_credits_in_cents / 100
  end

  def net_credits_in_cents
    credits.inject(0){|sum, c| sum += c.amount_in_cents}
  end

  def free_calls_completed
    calls.free.count
  end

  def free_calls_available
    promotions.has_free_calls.inject(0){|sum, promo| sum + promo.free_call_count}
  end

  def free_calls_remaining
    free_calls_available - free_calls_completed
  end

  def has_free_calls_remaining?
    free_calls_remaining > 0
  end

  # EXPERTS ONLY ==============================================================

  def rate_for(min)
    rate_per_minute * min
  end

  def rate_in_cents_for(min)
    rate_per_minute * min * 100
  end

  def avg_rating_as_expert
    avg_rating = calls_as_expert.average(:user_rating)
    avg_rating = avg_rating.nil? ? 0 : avg_rating
    if use_fake_rating
      fake_rating_value = fake_rating || 0
      return avg_rating if fake_rating_value == 0
      num_fake_ratings = 5
      (avg_rating + num_fake_ratings * fake_rating_value) / (num_fake_ratings + num_ratings)
    else
      avg_rating
    end
  end

  def num_comments_from_users
    if use_fake_comments
      fake_comments.count + calls_as_expert.reviewed_by_user.count
    else
      calls_as_expert.reviewed_by_user.count
    end
  end

  def num_ratings
    calls_as_expert.rated_by_user.count
  end

  private

  def ensure_auth_token
    if auth_token.blank? && !auth_token_changed?
      self.auth_token = generate_auth_token
    end
  end

  def generate_auth_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(auth_token: token).first
    end
  end
end
