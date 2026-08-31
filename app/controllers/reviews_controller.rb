# frozen_string_literal: true

class ReviewsController < ApplicationController
  before_action :set_user_phrase, only: :complete
  before_action :load_review_phrases, only: %i[index create]

  def index
    @result = current_user.diaries.find_by(id: params[:writing_id])
    @writing = current_user.diaries.build
  end

  def create
    @writing = current_user.diaries.build(writing_params)
    if @writing.save
      redirect_after_writing(@writing)
    else
      @result = nil
      flash.now[:alert] = '文章の投稿に失敗しました'
      render :index, status: :unprocessable_content
    end
  end

  def complete
    unless @user_phrase.due_for_review?
      redirect_to reviews_path, alert: '本日の復習対象ではありません'
      return
    end

    ReviewResultService.new(user_phrase: @user_phrase, correct: cast_boolean(params[:correct])).call
    redirect_to reviews_path, notice: '復習を記録しました'
  end

  private

  def load_review_phrases
    reset_stale_review_flags
    @user_phrases = current_user.user_phrases.pending_review.with_phrase
    @due_phrases = current_user.user_phrases.due_for_review.with_phrase
  end

  def redirect_after_writing(diary)
    phrases = @due_phrases.map { |user_phrase| user_phrase.phrase.content }
    if GeminiCorrectionService.new(diary, practice_phrases: phrases).call
      redirect_to reviews_path(writing_id: diary.id), notice: '添削が完了しました'
    else
      redirect_to reviews_path(writing_id: diary.id),
                  alert: '文章は保存しましたが、AI添削に失敗しました。時間をおいて再度お試しください。'
    end
  end

  def writing_params
    params.require(:review_writing).permit(:content)
  end

  def set_user_phrase
    @user_phrase = current_user.user_phrases.find(params[:id])
  end

  def reset_stale_review_flags
    current_user.user_phrases.due_for_review.where(review_completed: true).find_each do |user_phrase|
      user_phrase.update!(review_completed: false)
    end
  end

  def cast_boolean(value)
    ActiveModel::Type::Boolean.new.cast(value)
  end
end
