class CustomDevise::RegistrationsController < Devise::RegistrationsController

  def create
    super
    if params[:promo_code].present? && resource.errors.empty?
      promotion = Promotion.find_by_code(params[:promo_code].upcase)
      if promotion.present?
        resource.promotions << promotion
        flash[:notice] += "增加代码：#{params[:promo_code]}。"
      else
        flash[:notice] += "没有这个代码：#{params[:promo_code]}。"
      end
    end
    Emails::User.send_welcome(resource) if resource.id # only send if saved successfully
  end

  def update
    if params[:user][:password].present? && !resource.valid_password?(params[:user][:current_password])
      flash[:alert] = "你的密码不正确"
      return redirect_to edit_user_registration_path
    else
      super
    end
  end

  protected

  def update_resource(resource, params)
    params.delete(:current_password)
    resource.update_without_password(params)
  end

  def after_update_path_for(resource)
    edit_user_registration_path
  end

end 