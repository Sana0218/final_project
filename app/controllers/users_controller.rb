# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :require_login, only: %i[new create]
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to login_path, notice: 'ユーザー登録が完了しました'
    else
      flash.now[:alert] = 'ユーザー登録に失敗しました'
      render :new, status: :unprocessable_content
    end
  end
end

def user_params
  params.require(:user).permit(:name, :email, :password, :password_confirmation)
end
