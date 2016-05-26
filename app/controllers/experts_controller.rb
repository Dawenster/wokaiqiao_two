class ExpertsController < ApplicationController
  def index
    @tags = Tag.all
    if params[:t].present?
      if params[:s] == "price-up"
        @experts = Tag.find(params[:t]).experts.order("rate_per_minute ASC").page(params[:page])
      elsif params[:s] == "price-down"
        @experts = Tag.find(params[:t]).experts.order("rate_per_minute DESC").page(params[:page])
      else
        @experts = Tag.find(params[:t]).experts.order("domestic DESC").page(params[:page])
      end
    else
      if params[:s] == "price-up"
        @experts = User.experts.order("rate_per_minute ASC").page(params[:page])
      elsif params[:s] == "price-down"
        @experts = User.experts.order("rate_per_minute DESC").page(params[:page])
      else
        @experts = User.experts.order("domestic DESC").page(params[:page])
      end
    end
  end

  def book
    @call = Call.new
    @expert = User.find(params[:expert_id])
    if current_user && current_user == @expert
      flash[:alert] = "你不能与自己通话..."
      return redirect_to request.referrer || root_path
    end
    estimated_durations = [15, 30, 60]
    @estimated_call_durations = []
    estimated_durations.each do |duration|
      @estimated_call_durations << ["#{duration}分钟 (¥#{@expert.rate_for(duration)})", duration]
    end
    @user = User.new if current_user.nil?

    @available_times = default_available_times
    @today = Time.current
  end
end