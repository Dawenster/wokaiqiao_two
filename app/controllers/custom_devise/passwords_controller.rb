class CustomDevise::PasswordsController < Devise::PasswordsController

  def create
    if (@user = User.find_by_email(params[:user][:email].downcase))
      raw, enc = Devise.token_generator.generate(User, :reset_password_token)
      @user.reset_password_token = enc
      @user.reset_password_sent_at = Time.now.utc
      @user.save(validate: false)

      reset_link = edit_password_url(resource, :reset_password_token => raw)
      Emails::User.reset_password(resource, reset_link)

      flash[:notice] = "我们已经把重置的密码邮件发送到你的电邮。如果过了一会都没收到，请记得检查你的垃圾邮箱。"
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