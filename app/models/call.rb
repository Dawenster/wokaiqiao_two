class Call < ActiveRecord::Base
  
  belongs_to :expert, class_name: User, foreign_key: :expert_id
  belongs_to :user

  scope :unconfirmed, -> {
    where("user_accepted_at is null OR expert_accepted_at is null")
  }
  scope :completed, -> {
    where("scheduled_at < ?", Time.current)
  }

  PENDING_EXPERT_ACCEPTANCE = "申请处理中"
  PENDING_USER_ACCEPTANCE = "专家建议时间更改为"
  MUTUALLY_ACCEPTED = "通话确认"

  def status
    if user_accepted_at.present? && expert_accepted_at.nil?
      PENDING_EXPERT_ACCEPTANCE
    elsif user_accepted_at.nil? && expert_accepted_at.present?
      PENDING_USER_ACCEPTANCE
    elsif user_accepted_at.present? && expert_accepted_at.present?
      MUTUALLY_ACCEPTED
    end
  end
  
end
