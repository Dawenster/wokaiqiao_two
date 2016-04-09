class CallsController < ApplicationController

  before_action :auto_login, except: [:create]

  def create
    if current_user
      @user = current_user
    else
      @user = assign_user
      if !@user.save
        flash[:alert] = @user.errors.full_messages.join("，") + "。"
        redirect_to book_expert_path(params[:call][:expert_id]) and return
      else
        sign_in(:user, @user)
      end
    end

    @expert = User.find(params[:call][:expert_id])
    amount_to_charge = @expert.rate_in_cents_for(params[:call][:est_duration_in_min].to_i)

    customer = StripeTask.create_stripe_customer(@user, params[:stripe_token])
    StripeTask.charge(customer, amount_to_charge, "Chat with #{@expert.name}")

    merge_dates
    @call = Call.new(call_params)
    @call.user = @user
    @call.user_accepted_at = Time.current

    if @call.save
      flash[:notice] = "<strong>#{@user.name}</strong>，感谢你的通话申请！我们正在努力为你安排与<strong>#{@expert.name}</strong>直接通话。通话申请确认邮件已发送到你登记的电子邮箱，请查阅详情。你也可以在个人主页查看你的通话申请。"
      send_emails(@user, @expert, @call)
      redirect_to root_path
    else
      flash[:alert] = @calls.errors.full_messages.join("，") + "。"
      redirect_to root_path
    end
  end

  def index
    if params[:acceptor].present?
      @call = Call.find(params[:call_id])
      accept_call(@call)
    end
    @completed_calls = current_user.all_completed_calls
    @in_progress_calls = current_user.all_calls - @completed_calls
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
      :expert_accepted_at
    )
  end

  def merge_dates
    params[:call][:offer_time_one] = parse_text_into_date("#{params[:call][:offer_time_one_date]} #{params[:call][:offer_time_one_hour]}:00")
    params[:call][:offer_time_two] = parse_text_into_date("#{params[:call][:offer_time_two_date]} #{params[:call][:offer_time_two_hour]}:00")
    params[:call][:offer_time_three] = parse_text_into_date("#{params[:call][:offer_time_three_date]} #{params[:call][:offer_time_three_hour]}:00")
  end

  def assign_user
    User.new(
      name: params[:user_name],
      email: params[:user_email],
      password: params[:user_password]
    )
  end

  def send_emails(user, expert, call)
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

    Emails::Call.send_confirmation_to_user(user_data)
    Emails::Call.send_confirmation_to_expert(expert_data)
  end

  def accept_call(call)
    if params[:acceptor] == Call::EXPERT_ACCEPTOR_TEXT && call.expert == current_user
      call.accept_as_expert(params[:datetime_num].to_i)
      flash[:notice] = "谢谢你接受在<strong>#{ChineseTime.display(@call.scheduled_at)}</strong>和<strong>#{@call.user.name}</strong>通话"
    elsif params[:acceptor] == Call::USER_ACCEPTOR_TEXT && call.user == current_user
      call.accept_as_user(params[:datetime_num].to_i)
      flash[:notice] = "接受成功：<strong>#{ChineseTime.display(@call.scheduled_at)}</strong>和<strong>#{@call.expert.name}</strong>通话"
    end
  end

end