class CustomDevise::RegistrationsController < Devise::RegistrationsController

  def create
    super
    if params[:promo_code].present? && resource.errors.empty?
      promotion = Promotion.find_by_code(params[:promo_code].upcase)
      if promotion.present?
        resource.promotions << promotion
        flash[:notice] += "增加代码：#{params[:promo_code].upcase}。"
      else
        flash[:notice] += "没有这个代码：#{params[:promo_code].upcase}。"
      end
    end
    Emails::User.send_welcome(resource) if resource.id # only send if saved successfully
  end

  def update
    if params[:user][:password].present? && !resource.valid_password?(params[:user][:current_password])
      flash[:alert] = "你的密码不正确"
      return redirect_to edit_user_registration_path
    else
      self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
      prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

      resource_updated = update_resource(resource, account_update_params)
      
      if resource.errors.any?
        return redirect_to edit_user_registration_path 
      else
        flash_key = :updated
        set_flash_message :notice, flash_key
        return redirect_to after_update_path_for(resource)
      end
    end
  end

  protected

  def update_resource(resource, params)
    params.delete(:current_password)
    if !resource.update_without_password(params)
      flash[:alert] = resource.errors.full_messages.join("，") + "。"
    end
  end

  def after_update_path_for(resource)
    edit_user_registration_path
  end

end 