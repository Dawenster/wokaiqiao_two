class CallsController < ApplicationController

  def create
    if current_user
      @user = current_user
    else
      @user = User.new(
        name: params[:user_name],
        email: params[:user_email],
        password: params[:user_password]
      )
      if !@user.save
        flash[:alert] = @user.errors.full_messages.join("，") + "。"
        redirect_to book_expert_path(params[:call][:expert_id]) and return
      else
        sign_in(:user, @user)
      end
    end

    merge_dates
    @call = Call.new(call_params)
    @call.user = @user
    @call.user_accepted_at = Time.current
    @expert = User.find(params[:call][:expert_id])

    if @call.save
      flash[:notice] = "<strong>#{@user.name}</strong>，感谢您的通话申请！我们正在努力为您安排与<strong>#{@expert.name}</strong>直接通话。电子邮件已发送到您登记的电子邮箱，请查阅详情。"
      redirect_to root_path
    else
      flash[:alert] = @calls.errors.full_messages.join("，") + "。"
      redirect_to root_path
    end
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

end