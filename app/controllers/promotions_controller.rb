class PromotionsController < ApplicationController

  def index
    @credits = current_user.credits.order(:created_at)
  end

  def check
    promotion = Promotion.find_by_code(params[:code].upcase)
    if promotion.present? && current_user.promotions.where(id: promotion.id).any?
      flash[:alert] = "你已经加过了这个代码：#{params[:code]}"
    elsif promotion.present?
      Credit.create_for(current_user, promotion)
      current_user.promotions << promotion
      flash[:notice] = "成功加入代码：你的用户增加了¥#{promotion.amount}"
    elsif params[:code].blank?
      flash[:alert] = "请输入代码"
    else
      flash[:alert] = "没有这个代码：#{params[:code]}"
    end
    redirect_to promotions_path
  end

end