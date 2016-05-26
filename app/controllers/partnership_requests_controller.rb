class PartnershipRequestsController < ApplicationController
  def create
    @partnership_request = PartnershipRequest.new(partnership_request_params)

    if @partnership_request.save
      flash[:notice] = "<strong>#{@partnership_request.name}</strong>，感谢您填写您的相关信息！我们会尽快与您取得联系。"
      redirect_to partners_path
    else
      flash.now[:alert] = @partnership_request.errors.full_messages.join("，") + "。"
      render template: "pages/partners"
    end
  end

  protected

  def partnership_request_params
    params.require(:partnership_request).permit(
      :name,
      :school,
      :email
    )
  end
end