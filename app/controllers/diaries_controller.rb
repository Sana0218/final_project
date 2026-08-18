# frozen_string_literal: true

class DiariesController < ApplicationController
  before_action :set_diary, only: [:show]

  def index
    @diaries = current_user.diaries.order(created_at: :desc)
  end

  def show; end

  def new
    @diary = current_user.diaries.build
  end

  def create
    @diary = current_user.diaries.build(diary_params)
    if @diary.save
      redirect_to diaries_path, notice: '日記を投稿しました'
    else
      flash.now[:alert] = '日記の投稿に失敗しました'
      render :new, status: :unprocessable_content
    end
  end

  private

  def set_diary
    @diary = current_user.diaries.find(params[:id])
  end

  def diary_params
    params.require(:diary).permit(:content)
  end
end
