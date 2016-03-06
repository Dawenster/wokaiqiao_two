class Education < ActiveRecord::Base
  belongs_to :user

  def name_with_year
    "#{year}年#{name}"
  end
end
