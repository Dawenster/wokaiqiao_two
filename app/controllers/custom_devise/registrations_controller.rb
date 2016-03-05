class CustomDevise::RegistrationsController < Devise::RegistrationsController

  def create
    super
    Emails::User.send_welcome(resource)
  end

end 