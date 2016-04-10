class Call < ActiveRecord::Base
  
  belongs_to :expert, class_name: User, foreign_key: :expert_id
  belongs_to :user
  belongs_to :user_that_cancelled, class_name: User, foreign_key: :cancelled_by

  scope :unconfirmed, -> {
    where("user_accepted_at is null OR expert_accepted_at is null")
  }
  scope :completed, -> {
    where("scheduled_at < ?", Time.current)
  }
  scope :not_cancelled, -> {
    where(cancelled_at: nil)
  }

  PENDING_EXPERT_ACCEPTANCE = "申请处理中"
  PENDING_USER_ACCEPTANCE = "专家建议时间更改为"
  MUTUALLY_ACCEPTED = "通话确认"

  EXPERT_ACCEPTOR_TEXT = "expert"
  USER_ACCEPTOR_TEXT = "user"

  CANCELLATION_BUFFER_IN_HOURS_BEFORE_CALL_IS_CHARGED = 2
  CANCELLATION_BUFFER_IN_MINUTES_BEFORE_CALL_IS_CHARGED = 120
  MINUTES_TO_CHARGE_FOR_CANCELLATION = 15

  CONFERENCE_CALL_NUMBER = "+86-10-5904-5286"
  CONFERENCE_CALL_PARTICIPANT_CODE = "5773858"

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
    self.expert_accepted_at = Time.current
    self.scheduled_at = accepted_offer_time(num)
    self.save
  end

  def accept_as_user(num)
    self.user_accepted_at = Time.current
    self.scheduled_at = accepted_offer_time(num)
    self.save
  end

  def accepted_offer_time(num)
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

  def accepted?
    status == MUTUALLY_ACCEPTED
  end

  def cancellee
    user_that_cancelled == user ? expert : user
  end

  def apply_cancellation_fee?
    return false if scheduled_at.nil?
    cancelled_at > scheduled_at - CANCELLATION_BUFFER_IN_MINUTES_BEFORE_CALL_IS_CHARGED.minutes
  end

  def cancellation_fee
    # Charge 15 minutes if cancelled too late
    apply_cancellation_fee? ? MINUTES_TO_CHARGE_FOR_CANCELLATION * expert.rate_per_minute : 0
  end

  def person_to_action
    case status
    when PENDING_EXPERT_ACCEPTANCE
      expert
    when PENDING_USER_ACCEPTANCE
      user
    end
  end
  
end
