class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_english_in_rails_admin

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_in)        << :name
    devise_parameter_sanitizer.for(:sign_up)        << [:name, :phone, :agreed_to_policies]
    devise_parameter_sanitizer.for(:account_update) << [:name, :phone, :wechat]
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
    if params[:auth_token].present?
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

  def rails_admin_path(obj)
    request.base_url + rails_admin.show_path(model_name: obj.class.name.downcase, id: obj.id)
  end

  def general_email
    "team@wokaiqiao.com"
  end

  def default_available_times
    available_times = []
    7.upto(22) do |hour|
      hours_to_subtract = hour >= 13 ? 12 : 0
      available_times << ["#{hour >= 12 ? '下午' + (hour - hours_to_subtract).to_s : '上午' + hour.to_s}:00", "#{hour}:00"]
      available_times << ["#{hour >= 12 ? '下午' + (hour - hours_to_subtract).to_s : '上午' + hour.to_s}:30", "#{hour}:30"]
    end
    available_times
  end

  def check_for_admin
    if current_user && !current_user.is_admin?
      return redirect_to request.referrer || root_path, alert: "抱歉，你不是我开窍管理员之一"
    end
  end
end
