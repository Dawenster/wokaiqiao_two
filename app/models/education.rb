class Education < ActiveRecord::Base
  belongs_to :user

  validates :name,
            :user_id,
            presence: true

  def name_with_year
    if year
      "#{year}年#{name}"
    else
      name
    end
  end
end
