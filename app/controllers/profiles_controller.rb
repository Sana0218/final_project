# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :set_user, only: %i[show edit update line_link_token]

  def show; end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to profile_path, notice: 'プロフィールを更新しました'
    else
      flash.now[:alert] = 'プロフィールを更新できませんでした'
      render :edit, status: :unprocessable_content
    end
  end

  def line_link_token
    @user.generate_line_link_token!
    redirect_to profile_path, notice: 'LINE連携コードを発行しました'
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    permitted = params.require(:user).permit(
      :name, :email, :password, :password_confirmation,
      :reminder_enabled, :reminder_hour, :reminder_minute, :time_zone
    )
    return permitted.except(:password, :password_confirmation) if permitted[:password].blank?

    permitted
  end
end
