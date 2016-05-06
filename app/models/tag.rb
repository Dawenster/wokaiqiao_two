class Tag < ActiveRecord::Base
  has_and_belongs_to_many :experts, class_name: User, join_table: "experts_tags", association_foreign_key: "expert_id", uniq: true

  validates :name, presence: true
end
