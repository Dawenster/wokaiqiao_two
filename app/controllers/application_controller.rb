class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_english_in_rails_admin

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_in)        << :name
    devise_parameter_sanitizer.for(:sign_up)        << :name
    devise_parameter_sanitizer.for(:account_update) << :name
  end

  def set_english_in_rails_admin
    if self.kind_of? RailsAdmin::ApplicationController
      I18n.locale = :en
    else
      I18n.locale = :zh
    end
  end

  def parse_text_into_date(date_text)
    zone = "Beijing"
    ActiveSupport::TimeZone[zone].parse(date_text)
  end

  def email_link_for_calls(user)
    calls_url(auth_token: user.auth_token)
  end

  def email_link_for_accepting_calls(user, call, num, acceptor)
    calls_url(auth_token: user.auth_token, call_id: call.id, datetime_num: num, acceptor: acceptor, anchor: call.anchor_tag)
  end

  def auto_login
    if params[:auth_token].present? && current_user.nil?
      user = User.find_by_auth_token(params[:auth_token])
      sign_in(user) if user.present?
    end
    redirect_to_root_if_not_logged_in
  end

  def redirect_to_root_if_not_logged_in
    if current_user.nil?
      flash[:alert] = "请先登录帐户"
      return redirect_to root_path
    end
  end
end
