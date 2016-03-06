class Call < ActiveRecord::Base
  
  belongs_to :expert, class_name: User, foreign_key: :expert_id
  belongs_to :user
  
end
