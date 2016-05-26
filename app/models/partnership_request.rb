class PartnershipRequest < ActiveRecord::Base
  validates :name,
            :school, presence: true
  validates :email, presence: true, email: true
end
