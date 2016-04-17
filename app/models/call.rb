class Call < ActiveRecord::Base
  
  belongs_to :expert, class_name: User, foreign_key: :expert_id
  belongs_to :user
  belongs_to :user_that_cancelled, class_name: User, foreign_key: :cancelled_by
  has_many :payments

  scope :unconfirmed, -> {
    where("user_accepted_at is null OR expert_accepted_at is null")
  }
  scope :completed, -> {
    where("scheduled_at < ?", Time.current)
  }
  scope :not_cancelled, -> {
    where(cancelled_at: nil)
  }

  after_save :after_call_payments_or_adjustments, if: :call_completed?

  validates :est_duration_in_min,
            :user_id,
            :expert_id,
            :offer_time_one,
            :offer_time_two,
            :offer_time_three,
            presence: true
  validate :call_ends_after_start

  PENDING_EXPERT_ACCEPTANCE = "申请处理中"
  PENDING_USER_ACCEPTANCE = "专家建议时间更改为"
  MUTUALLY_ACCEPTED = "通话确认"

  EXPERT_ACCEPTOR_TEXT = "expert"
  USER_ACCEPTOR_TEXT = "user"

  CANCELLATION_BUFFER_IN_HOURS_BEFORE_CALL_IS_CHARGED = 2
  CANCELLATION_BUFFER_IN_MINUTES_BEFORE_CALL_IS_CHARGED = CANCELLATION_BUFFER_IN_HOURS_BEFORE_CALL_IS_CHARGED * 60
  MINUTES_TO_CHARGE_FOR_CANCELLATION = 15

  CONFERENCE_CALL_NUMBER = "+86 (0) 510 6801 0107"
  CONFERENCE_CALL_ADMIN_CODE = "953026"
  CONFERENCE_CALL_PARTICIPANT_CODE = "476513"

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

  def other_user(current_user)
    user == current_user ? expert : user
  end

  def change_user_or_expert_accepted_at(current_user)
    if current_user.is_user_in?(self)
      self.user_accepted_at = Time.current
      self.expert_accepted_at = nil
    else
      self.user_accepted_at = nil
      self.expert_accepted_at = Time.current
    end
    self
  end

  def actual_duration_in_min
    # Rounded down
    ((ended_at - started_at) / 60).floor
  end

  def cost_in_cents
    actual_duration_in_min * expert.rate_per_minute * 100
  end

  def payment_required?
    total_paid_in_cents < cost_in_cents
  end

  def payment_amount
    cost_in_cents - total_paid_in_cents
  end

  def refund_required?
    total_paid_in_cents > cost_in_cents
  end

  def overage_refund_amount
    total_paid_in_cents - cost_in_cents
  end

  def total_paid_in_cents
    payments.sum(:amount_in_cents)
  end

  def total_refunded_in_cents
    payments.inject(0) { |sum, p| sum += p.total_refunds_in_cents }
  end

  def net_paid
    total_paid_in_cents - total_refunded_in_cents
  end

  def cancelled_too_late?
    Time.current > scheduled_at - CANCELLATION_BUFFER_IN_MINUTES_BEFORE_CALL_IS_CHARGED.minutes
  end

  def has_positive_paid_balance?
    net_paid > 0
  end

  def amount_for_early_cancellation_in_cents
    MINUTES_TO_CHARGE_FOR_CANCELLATION * expert.rate_per_minute * 100
  end

  def need_to_pay_after_cancellation?
    amount_for_early_cancellation_in_cents < net_paid
  end

  def need_to_refund_after_cancellation?
    amount_for_early_cancellation_in_cents > net_paid
  end

  def payment_amount_for_early_cancellation
    amount_for_early_cancellation_in_cents - net_paid
  end

  def refund_amount_for_early_cancellation
    net_paid - amount_for_early_cancellation_in_cents
  end

  private

  def call_ends_after_start
    if ended_at.present? && started_at.present? && ended_at < started_at
      errors.add(:ended_at, "cannot be before started_at")
    end
  end

  def call_completed?
    ended_at_changed? &&
    started_at.present? &&
    ended_at.present?
  end

  def after_call_payments_or_adjustments
    customer = StripeTask.customer(user)
    if payment_required?
      charge = StripeTask.charge(customer, payment_amount, "和#{expert.name}通话")
      Payment.make(user, self, charge)
    elsif refund_required?
      Refund.refund_call(self, overage_refund_amount, customer)
    end
  end
  
end
