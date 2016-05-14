class Call < ActiveRecord::Base
  
  belongs_to :expert, class_name: User, foreign_key: :expert_id
  belongs_to :user
  belongs_to :user_that_cancelled, class_name: User, foreign_key: :cancelled_by
  has_many :credits
  has_many :payments
  has_one :payout

  scope :unconfirmed, -> {
    where("user_accepted_at is null OR expert_accepted_at is null")
  }
  scope :completed, -> {
    where("started_at is not null AND ended_at is not null")
  }
  scope :cancelled, -> {
    where.not(cancelled_at: nil)
  }
  scope :not_cancelled, -> {
    where(cancelled_at: nil)
  }
  scope :reviewed_by_user, -> {
    where.not(user_review: [nil, ""])
  }

  after_save :tasks_after_call_completion, if: :call_completed?

  validates :est_duration_in_min,
            :user_id,
            :expert_id,
            :offer_time_one,
            :offer_time_two,
            :offer_time_three,
            presence: true
  validate :call_ends_after_start
  validate :user_is_not_expert

  CALL_CANCELLED = "通话取消"
  CALL_COMPLETED = "通话已完成"
  PENDING_EXPERT_ACCEPTANCE = "申请处理中"
  PENDING_USER_ACCEPTANCE = "专家建议时间更改为"
  MUTUALLY_ACCEPTED = "通话确认"

  EXPERT_ACCEPTOR_TEXT = "expert"
  USER_ACCEPTOR_TEXT = "user"

  CANCELLATION_BUFFER_IN_HOURS_BEFORE_CALL_IS_CHARGED = 2
  CANCELLATION_BUFFER_IN_MINUTES_BEFORE_CALL_IS_CHARGED = CANCELLATION_BUFFER_IN_HOURS_BEFORE_CALL_IS_CHARGED * 60
  MINUTES_TO_CHARGE_FOR_CANCELLATION = 15
  HOURS_TO_WAIT_FOR_EXPERT_TO_REPLY = 72

  CONFERENCE_CALL_NUMBER = "+86 (0) 510 6801 0107"
  CONFERENCE_CALL_ADMIN_CODE = "953026"
  CONFERENCE_CALL_PARTICIPANT_CODE = "476513"

  # GENERAL =======================================================

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

  def actual_duration_in_min
    # Rounded down
    ((ended_at - started_at) / 60).floor
  end

  # STATUS =======================================================

  def status
    return CALL_CANCELLED            if cancelled?
    return CALL_COMPLETED            if completed?
    return PENDING_EXPERT_ACCEPTANCE if pending_expert_acceptance?
    return PENDING_USER_ACCEPTANCE   if pending_user_acceptance?
    return MUTUALLY_ACCEPTED         if accepted?
  end

  def cancelled?
    cancelled_at.present?
  end

  def completed?
    started_at.present? && ended_at.present?
  end

  def pending_expert_acceptance?
    user_accepted_at.present? && expert_accepted_at.nil?
  end

  def pending_user_acceptance?
    user_accepted_at.nil? && expert_accepted_at.present?
  end

  def accepted?
    user_accepted_at.present? && expert_accepted_at.present?
  end

  # CANCELLATION =======================================================

  def cancellee
    user_that_cancelled == user ? expert : user
  end

  def cancelled_by_user?
    cancellee == user
  end

  def would_be_charged_cancellation_fee?
    return false if scheduled_at.nil?
    Time.current > scheduled_at - CANCELLATION_BUFFER_IN_MINUTES_BEFORE_CALL_IS_CHARGED.minutes
  end

  def apply_cancellation_fee?
    return false if scheduled_at.nil?
    cancelled_at > scheduled_at - CANCELLATION_BUFFER_IN_MINUTES_BEFORE_CALL_IS_CHARGED.minutes
  end

  def pure_cancellation_fee
    MINUTES_TO_CHARGE_FOR_CANCELLATION * expert.rate_per_minute
  end

  def cancellation_fee
    # Charge amount if cancelled too late
    apply_cancellation_fee? ? pure_cancellation_fee : 0
  end

  def cancellation_fee_in_cents
    cancellation_fee * 100
  end

  # CUSTOMER PAYMENT / COSTS =======================================================

  def cost
    actual_duration_in_min * expert.rate_per_minute
  end

  def cost_in_cents
    cost * 100
  end

  def payment_required?
    total_paid_in_cents < cost_in_cents - applicable_credits_in_cents
  end

  def payment_amount
    cost_in_cents - total_paid_in_cents - applicable_credits_in_cents
  end

  def refund_required?
    total_paid_in_cents > cost_in_cents - applicable_credits_in_cents
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

  def has_positive_paid_balance?
    net_paid > 0
  end

  def need_to_pay_after_cancellation?
    cancellation_fee_in_cents > net_paid
  end

  def need_to_refund_after_cancellation?
    cancellation_fee_in_cents < net_paid
  end

  def payment_amount_for_early_cancellation
    cancellation_fee_in_cents - net_paid
  end

  def refund_amount_for_early_cancellation
    net_paid - cancellation_fee_in_cents
  end

  def applicable_credits_in_cents
    # Lesser between credits and amount owing
    # Greater between amount owing and 0 (in case amount owing is negative)
    [[user.net_credits_in_cents, cost_in_cents - total_paid_in_cents].min, 0].max
  end

  # EXPERT PAYOUTS =======================================================

  def expert_payout
    cost - admin_fee
  end

  def expert_payout_in_cents
    cost_in_cents - admin_fee_in_cents
  end

  def admin_fee
    admin_fee_in_cents / 100
  end

  def admin_fee_in_cents
    # Round down to the nearest hundred (元) for us so there are no cents
    ((cost_in_cents * Payout::ADMIN_FEE_PERCENTAGE / 100) * 100).ceil / 100
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

  def tasks_after_call_completion
    customer = StripeTask.customer(user)
    amount_already_collected = total_paid_in_cents / 100
    credits_applied = applicable_credits_in_cents / 100
    original_payment = payment_amount / 100

    if payment_required?

      charge = StripeTask.charge(customer, payment_amount, "与#{expert.name}通话")
      Credit.user_on(self, applicable_credits_in_cents) if applicable_credits_in_cents > 0
      Payment.make(user, self, charge)

    elsif refund_required?

      Refund.refund_call(self, overage_refund_amount, cost_in_cents, customer)
      
    end

    Payout.make_for_call(self)
    Emails::Call.send_call_completion_to_user(self, amount_already_collected, original_payment, credits_applied)
    Emails::Call.send_call_completion_to_expert(self)
  end

  def user_is_not_expert
    if user == expert
      errors.add(:user_id, "cannot be same as expert")
    end
  end
  
end
