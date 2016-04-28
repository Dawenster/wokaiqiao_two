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
  validates :name, :email, presence: true

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
    calls.not_cancelled + calls_as_expert.not_cancelled
  end

  def all_completed_calls
    calls.completed + calls_as_expert.completed
  end

  def all_cancelled_calls
    calls.cancelled + calls_as_expert.cancelled
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

  # EXPERTS ONLY ==============================================================

  def rate_for(min)
    rate_per_minute * min
  end

  def rate_in_cents_for(min)
    rate_per_minute * min * 100
  end

  def avg_rating_as_expert
    avg_rating = calls_as_expert.average(:user_rating).to_s
    avg_rating.nil? ? 0 : avg_rating
  end

  def num_comments_from_users
    calls_as_expert.reviewed_by_user.count
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
