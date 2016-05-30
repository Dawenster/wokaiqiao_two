class ExpertsController < ApplicationController
  def index
    @tags = Tag.all

    if params[:t].present?

      if params[:s] == User::PRICE_UP
        @experts = Tag.find(params[:t]).experts.order("rate_per_minute ASC, id ASC").page(params[:page])
      elsif params[:s] == User::PRICE_DOWN
        @experts = Tag.find(params[:t]).experts.order("rate_per_minute DESC, id ASC").page(params[:page])
      elsif params[:s] == User::HIGHEST_RATING
        sorted_experts = Tag.find(params[:t]).experts.sort_by(&:avg_rating_as_expert).reverse
        @experts = Kaminari.paginate_array(sorted_experts).page(params[:page]).per(10)
      elsif params[:s] == User::MOST_COMMENTS
        sorted_experts = Tag.find(params[:t]).experts.sort_by(&:num_comments_from_users).reverse
        @experts = Kaminari.paginate_array(sorted_experts).page(params[:page]).per(10)
      else # Default to sort by domestic
        @experts = Tag.find(params[:t]).experts.order("domestic DESC, id ASC").page(params[:page])
      end

    else

      if params[:s] == User::PRICE_UP
        @experts = User.experts.order("rate_per_minute ASC, id ASC").page(params[:page])
      elsif params[:s] == User::PRICE_DOWN
        @experts = User.experts.order("rate_per_minute DESC, id ASC").page(params[:page])
      elsif params[:s] == User::HIGHEST_RATING
        sorted_experts = User.experts.sort_by(&:avg_rating_as_expert).reverse
        @experts = Kaminari.paginate_array(sorted_experts).page(params[:page]).per(10)
      elsif params[:s] == User::MOST_COMMENTS
        sorted_experts = User.experts.sort_by(&:num_comments_from_users).reverse
        @experts = Kaminari.paginate_array(sorted_experts).page(params[:page]).per(10)
      else # Default to sort by domestic
        @experts = User.experts.order("domestic DESC, id ASC").page(params[:page])
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