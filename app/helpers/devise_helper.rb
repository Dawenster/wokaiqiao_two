module DeviseHelper
  def devise_error_messages!
    if resource.errors.empty?
      flash[:alert] = nil
      return '' 
    else
      messages = resource.errors.full_messages.join("，") + "。"
      flash[:alert] = messages
    end
  end
end