# frozen_string_literal: true

class DiariesController < ApplicationController
  before_action :set_diary, only: %i[show save_phrases]

  def index
    @diaries = current_user.diaries.ordered
  end

  def show; end

  def save_phrases
    saved = PhraseSaveService.new(user: current_user, phrase_contents: params[:phrase_contents]).call
    if saved.any?
      redirect_to diary_path(@diary), notice: "#{saved.size}件のフレーズを保存しました"
    else
      redirect_to diary_path(@diary), alert: '保存するフレーズを選択してください'
    end
  end

  def new
    @diary = current_user.diaries.build
  end

  def create
    @diary = current_user.diaries.build(diary_params)
    if @diary.save
      GeminiCorrectionService.new(@diary).call
      redirect_to diary_path(@diary), notice: '日記を投稿しました'
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
