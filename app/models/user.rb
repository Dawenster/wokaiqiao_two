class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_attached_file :picture,
                    styles: { medium: "300x300#", thumb: "100x100#" },
                    default_url: "https://s3-us-west-2.amazonaws.com/wokaiqiao/users/missing-user.png",
                    storage: :s3,
                    s3_credentials: Proc.new{|a| a.instance.s3_credentials }

  validates_attachment_content_type :picture, content_type: /\Aimage\/.*\Z/
  validates :name, presence: true

  before_save :ensure_auth_token

  scope :admin, -> {
    where(admin: true)
  }
  scope :experts, -> {
    where(expert: true)
  }

  has_many :calls
  has_many :calls_as_expert, class_name: Call, foreign_key: :expert_id
  has_many :educations

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

  def rate_for(min)
    rate_per_minute * min
  end

  def rate_in_cents_for(min)
    rate_per_minute * min * 100
  end

  def all_calls
    calls + calls_as_expert
  end

  def all_completed_calls
    calls.completed + calls_as_expert.completed
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
