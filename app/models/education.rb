class Education < ActiveRecord::Base
  belongs_to :user

  validates :name,
            :user_id,
            presence: true

  def name_with_year
    "#{year}年#{name}"
  end
end
