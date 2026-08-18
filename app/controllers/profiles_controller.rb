class ProfilesController < ApplicationController
  before_action :set_user, only: %i[show edit update]
  def show;  end

  def edit;  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'プロフィールを更新しました'
    else
      flash.now[:alert] = 'プロフィールを更新できませんでした'
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
