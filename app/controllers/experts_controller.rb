class ExpertsController < ApplicationController
  def index
    @experts = User.experts
  end

  def book
    
  end
end