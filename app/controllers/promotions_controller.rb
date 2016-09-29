class PromotionsController < ApplicationController

  before_filter :authenticate_user!

  def index
    @credits = current_user.credits.order(:created_at)
  end

  def check
    promotion = Promotion.find_by_code(params[:code].upcase)
    if promotion.present? && current_user.promotions.where(id: promotion.id).any?
      flash[:alert] = "你已经加过了这个代码：#{params[:code]}"
    elsif promotion.present?
      flash[:notice] = "成功激活折扣代码："
      promo_details = []

      if promotion.has_credits?
        Credit.create_for(current_user, promotion)
        promo_details << "增加¥#{promotion.amount}金额"
      end

      if promotion.has_free_calls?
        promo_details << "增加#{promotion.free_call_count}个免费通话"
      end

      current_user.promotions << promotion
      flash[:notice] += promo_details.join("，")
    elsif params[:code].blank?
      flash[:alert] = "请输入代码"
    else
      flash[:alert] = "没有这个代码：#{params[:code]}"
    end
    redirect_to promotions_path
  end

end