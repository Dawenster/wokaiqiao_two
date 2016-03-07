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
end
