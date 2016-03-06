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

  scope :experts, -> {
    where(expert: true)
  }

  has_many :educations

  def s3_credentials
    {
      bucket: ENV['AWS_BUCKET'],
      access_key_id: ENV["AWS_ACCESS_KEY"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
    }
  end
end
