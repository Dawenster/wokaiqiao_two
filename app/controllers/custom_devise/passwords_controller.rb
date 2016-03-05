class CustomDevise::PasswordsController < Devise::PasswordsController

  def create
    if (@user = User.find_by_email(params[:user][:email].downcase))
      raw, enc = Devise.token_generator.generate(User, :reset_password_token)
      @user.reset_password_token = enc
      @user.reset_password_sent_at = Time.now.utc
      @user.save(validate: false)

      reset_link = edit_password_url(resource, :reset_password_token => (Devise::VERSION.start_with?('3.') ? raw : resource.reset_password_token))
      Emails::User.reset_password(resource, reset_link)

      flash[:notice] = "几分钟后，您将收到重置密码的电子邮件。"
      redirect_to root_path
    else
      if params[:user][:email].blank?
        flash[:notice] = "请填入邮件"
      else
        flash[:notice] = "找不到邮件： #{params[:user][:email]}"
      end
      redirect_to new_password_path(User)
    end
  end

end 