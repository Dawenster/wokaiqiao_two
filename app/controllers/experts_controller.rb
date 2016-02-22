class ExpertsController < ApplicationController
  def index
    @experts = User.experts
  end
end