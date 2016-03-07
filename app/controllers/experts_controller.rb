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
    @available_times = []
    7.upto(22) do |hour|
      hours_to_subtract = hour >= 13 ? 12 : 0
      @available_times << ["#{hour >= 12 ? '下午' + (hour - hours_to_subtract).to_s : '上午' + hour.to_s}:00", "#{hour}:00"]
      @available_times << ["#{hour >= 12 ? '下午' + (hour - hours_to_subtract).to_s : '上午' + hour.to_s}:30", "#{hour}:30"]
    end
    @today = Time.current
  end
end