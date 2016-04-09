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

  EXPERT_ACCEPTOR_TEXT = "expert"
  USER_ACCEPTOR_TEXT = "user"

  def status
    if user_accepted_at.present? && expert_accepted_at.nil?
      PENDING_EXPERT_ACCEPTANCE
    elsif user_accepted_at.nil? && expert_accepted_at.present?
      PENDING_USER_ACCEPTANCE
    elsif user_accepted_at.present? && expert_accepted_at.present?
      MUTUALLY_ACCEPTED
    end
  end

  def accept_as_expert(num)
    self.expert_accepted_at = time_of_acceptance(num)
    self.save
  end

  def accept_as_user(num)
    self.user_accepted_at = time_of_acceptance(num)
    self.save
  end

  def time_of_acceptance(num)
    case num
    when 1
      offer_time_one
    when 2
      offer_time_two
    when 3
      offer_time_three
    end
  end

  def anchor_tag
    "call-anchor-#{id}"
  end
  
end
