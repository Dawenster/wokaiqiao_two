class ExpertsController < ApplicationController
  def index
    @experts = User.experts
  end

  def book
    @call = Call.new
    @expert = User.find(params[:expert_id])
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