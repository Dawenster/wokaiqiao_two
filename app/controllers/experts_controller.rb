class ExpertsController < ApplicationController
  def index
    @experts = User.experts
  end

  def book
    @call = Call.new
    @expert = User.find(params[:expert_id])
  end
end