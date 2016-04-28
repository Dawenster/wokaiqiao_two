class PromotionsController < ApplicationController

  def index
    @promotions = current_user.promotions
  end

  def check
    promotion = Promotion.find_by_code(params[:code].upcase)
    if promotion.present? && current_user.promotions.where(id: promotion.id).any?
      flash[:alert] = "你已经加过了这个代码：#{params[:code]}"
    elsif promotion.present?
      Credit.create_for(current_user, promotion)
      current_user.promotions << promotion
      flash[:notice] = "成功加入代码：你的用户增加了¥#{promotion.amount}"
    else
      flash[:alert] = "没有这个代码：#{params[:code]}"
    end
    redirect_to promotions_path
  end

end