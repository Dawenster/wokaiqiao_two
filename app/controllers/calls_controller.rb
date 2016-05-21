class CallsController < ApplicationController

  before_action :auto_login, except: [:create]

  def create
    if current_user
      @user = current_user
    else
      @user = User.new(user_params)
      if !@user.save
        flash[:alert] = @user.errors.full_messages.join("，") + "。"
        redirect_to book_expert_path(params[:call][:expert_id]) and return
      else
        sign_in(:user, @user)
      end
    end

    @expert = User.find(params[:call][:expert_id])
    amount_to_charge = @expert.rate_in_cents_for(params[:call][:est_duration_in_min].to_i)

    unless @user.stripe_cus_id.present?
      customer = StripeTask.create_stripe_customer(@user, params[:stripe_token])
      @charge = StripeTask.charge(customer, amount_to_charge, "与#{@expert.name}通话")
      if StripeTask.failed_charge?(@charge)
        customer.delete
        @user.update_attributes(stripe_cus_id: nil)
        flash[:alert] = @charge[:error_message] + "。"
        redirect_to book_expert_path(params[:call][:expert_id]) and return
      end
    end

    merge_dates
    @call = Call.new(call_params)
    @call.user = @user
    @call.user_accepted_at = Time.current

    if @call.save
      Payment.make(@user, @call, @charge) if @charge
      flash[:notice] = "<strong>#{@user.name}</strong>，感谢你的通话申请！我们正在努力为你安排与<strong>#{@expert.name}</strong>直接通话。通话申请确认邮件已发送到你登记的电子邮箱，请查阅详情。你也可以在个人主页查看你的通话申请。"
      send_confirmation_emails(@user, @expert, @call)
      redirect_to calls_path
    else
      flash[:alert] = @calls.errors.full_messages.join("，") + "。"
      redirect_to experts_path
    end
  end

  def index
    if params[:acceptor].present?
      @call = Call.find(params[:call_id])
      accept_call(@call)
    end
    @completed_calls = current_user.all_completed_calls
    @in_progress_calls = current_user.all_calls - @completed_calls
    @cancelled_calls = current_user.all_cancelled_calls
    @available_times = default_available_times
    @today = Time.current
  end

  def accept
    @call = Call.find(params[:id])
    accept_call(@call)
    redirect_to calls_path
  end

  def update
    @call = Call.find(params[:id])
    merge_dates if datetimes_passed_in
    @call.assign_attributes(call_params)
    new_time_offered = datetimes_changed(@call)
    @call = @call.change_user_or_expert_accepted_at(current_user) if datetimes_changed(@call)
    if @call.save
      send_edit_call_email(@call) if new_time_offered
      flash[:notice] = "成功更改与#{@call.other_user(current_user).name}的通话申请"
    else
      flash[:alert] = @call.errors.full_messages.join("，") + "。"
    end
    redirect_to calls_path
  end

  def rate
    @call = Call.find(params[:id])
    @call.assign_attributes(call_params)
    if current_user.is_user_in?(@call) && @call.user_review.present?
      @call.user_review_left_at = Time.current
    elsif current_user.is_expert_in?(@call) && @call.expert_review.present?
      @call.expert_review_left_at = Time.current
    end

    if @call.save
      flash[:notice] = "感谢你给#{@call.expert.name}留了评论"
    else
      flash[:alert] = @call.errors.full_messages.join("，") + "。"
    end
    redirect_to calls_path(t: "completed")
  end

  def rate_with_rating
    @call = Call.find(params[:id])
    if current_user.is_user_in?(@call)
      @call.update_attributes(user_rating: params[:r])
      flash[:notice] = "感谢你给#{@call.expert.name}留了评论"
    elsif current_user.is_expert_in?(@call)
      @call.update_attributes(expert_rating: params[:r])
      flash[:notice] = "感谢你给#{@call.user.name}留了评论"
    end
    redirect_to calls_path(t: "completed", openRating: @call.id)
  end

  def cancel
    @call = Call.find(params[:id])
    @call.assign_attributes(call_params)
    @call.cancelled_at = Time.current
    @call.user_that_cancelled = current_user

    if @call.accepted? && @call.cancelled_by_user? && @call.apply_cancellation_fee?
      if @call.need_to_pay_after_cancellation?
        customer = StripeTask.customer(@call.user)
        charge = StripeTask.charge(customer, @call.payment_amount_for_early_cancellation, "与#{@call.expert.name}通话提早取消")
        Payment.make(@call.user, @call, charge)
      elsif @call.need_to_refund_after_cancellation?
        customer = StripeTask.customer(@call.user)
        Refund.refund_call(@call, @call.refund_amount_for_early_cancellation, @call.cancellation_fee_in_cents, customer)
      end
    elsif @call.accepted? && @call.has_positive_paid_balance?
      customer = StripeTask.customer(@call.user)
      Refund.refund_call(@call, @call.net_paid, 0, customer)
    end

    if @call.save
      send_cancellation_emails(@call)
      flash[:notice] = "取消了你与#{@call.cancellee.name}的通话"
    else
      flash[:alert] = @call.errors.full_messages.join("，") + "。"
    end
    redirect_to calls_path(t: "cancelled")
  end

  protected

  def call_params
    params.require(:call).permit(
      :description,
      :est_duration_in_min,
      :user_id,
      :expert_id,
      :user_rating,
      :expert_rating,
      :user_review,
      :expert_review,
      :offer_time_one,
      :offer_time_two,
      :offer_time_three,
      :scheduled_at,
      :user_accepted_at,
      :expert_accepted_at,
      :cancellation_reason
    )
  end

  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :password,
      :agreed_to_policies
    )
  end

  def merge_dates
    params[:call][:offer_time_one] = parse_text_into_date("#{params[:call][:offer_time_one_date]} #{params[:call][:offer_time_one_hour]}:00")
    params[:call][:offer_time_two] = parse_text_into_date("#{params[:call][:offer_time_two_date]} #{params[:call][:offer_time_two_hour]}:00")
    params[:call][:offer_time_three] = parse_text_into_date("#{params[:call][:offer_time_three_date]} #{params[:call][:offer_time_three_hour]}:00")
  end

  def send_confirmation_emails(user, expert, call)
    user_data = expert_data = {
      user: user,
      expert: expert,
      call: call,
      link_to_manage_calls: email_link_for_calls(user)
    }
    expert_data[:link_to_manage_calls] = email_link_for_calls(expert)
    expert_data[:link_to_accept_call_one] = email_link_for_accepting_calls(expert, call, 1, Call::EXPERT_ACCEPTOR_TEXT)
    expert_data[:link_to_accept_call_two] = email_link_for_accepting_calls(expert, call, 2, Call::EXPERT_ACCEPTOR_TEXT)
    expert_data[:link_to_accept_call_three] = email_link_for_accepting_calls(expert, call, 3, Call::EXPERT_ACCEPTOR_TEXT)

    Emails::Call.send_confirmation_of_call_request_to_user(user_data)
    Emails::Call.send_initial_request_to_expert(expert_data)
    Emails::Call.send_request_notification_to_admin(user_data, rails_admin_path(call), general_email)
  end

  def send_edit_call_email(call)
    receiver = call.other_user(current_user)
    role = receiver.role_in(call)
    data = {
      call: call,
      receiver: receiver,
      editing_user: current_user,
      link_to_manage_calls: email_link_for_calls(receiver),
      link_to_accept_call_one: email_link_for_accepting_calls(receiver, call, 1, role),
      link_to_accept_call_two: email_link_for_accepting_calls(receiver, call, 2, role),
      link_to_accept_call_three: email_link_for_accepting_calls(receiver, call, 3, role)
    }
    Emails::Call.edit_request(data)
  end

  def accept_call(call)
    if params[:acceptor] == Call::EXPERT_ACCEPTOR_TEXT && call.expert == current_user
      call.accept_as_expert(params[:datetime_num].to_i)
      flash[:notice] = "谢你接受在<strong>#{ChineseTime.display(call.scheduled_at)}</strong>与<strong>#{call.user.name}</strong>通话"
    elsif params[:acceptor] == Call::USER_ACCEPTOR_TEXT && call.user == current_user
      call.accept_as_user(params[:datetime_num].to_i)
      flash[:notice] = "接受成功：<strong>#{ChineseTime.display(call.scheduled_at)}</strong>与<strong>#{call.expert.name}</strong>通话"
    end
    call.set_conference_details
    send_confirmation_of_calls_emails(call)
  end

  def send_confirmation_of_calls_emails(call)
    Emails::Call.send_call_acceptance_confirmation(call, email_link_for_calls(call.user), Call::USER_ACCEPTOR_TEXT)
    Emails::Call.send_call_acceptance_confirmation(call, email_link_for_calls(call.expert), Call::EXPERT_ACCEPTOR_TEXT)
    Emails::Call.send_call_acceptance_confirmation_to_admin(call, rails_admin_path(call), general_email)
  end

  def send_cancellation_emails(call)
    Emails::Call.send_cancel_notice(call, email_link_for_calls(call.cancellee))
    Emails::Call.send_cancellation_notice_to_admin(call, rails_admin_path(call), general_email)
  end

  def datetimes_passed_in
    params[:call][:offer_time_one_date].present? &&
    params[:call][:offer_time_two_date].present? &&
    params[:call][:offer_time_three_date].present?
  end

  def datetimes_changed(call)
    call.offer_time_one_changed? || call.offer_time_two_changed? || call.offer_time_three_changed?
  end

end