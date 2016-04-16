class Charge < ActiveRecord::Base
  belongs_to :call
  belongs_to :user
end
