class PartnershipRequest < ActiveRecord::Base
  validates :name,
            :school,
            :email,
            presence: true
end
