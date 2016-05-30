class UsersController < ApplicationController

  before_filter :authenticate_user!
  before_filter :user_can_make_changes

  def update
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

  def user_can_make_changes
    @user = User.find(params[:id])
    if @user != current_user
      flash[:alert] = "请别乱来..."
      redirect_to request.referrer || root_path
    end
  end

end