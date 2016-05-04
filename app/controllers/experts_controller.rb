class ExpertsController < ApplicationController
  def index
    @experts = User.experts.page params[:page]
    # @paginatable_experts = Kaminari.paginate_array(@experts).page(params[:page]).per(10)
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