class UsersController < ApplicationController

  before_filter :authenticate_user!

  def show
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    @user.assign_attributes(user_params)
    if @user.save
      flash[:notice] = "成功更新"
      redirect_to user_path(@user)
    else
      flash.now[:alert] = @user.errors.full_messages.join("，") + "。"
      render "show"
    end
  end

  protected

  def user_params
    params.require(:user).permit(
      :description,
      :current_work,
      :rate_per_minute,
      :past_work,
      :languages,
      :location,
      :domestic,
      :title,
      :picture,
      {:tag_ids => []},
      :educations_attributes => [
        :id,
        :name,
        :year,
        :user_id,
        :_destroy
      ]
    )
  end

end