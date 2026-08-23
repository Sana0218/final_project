# frozen_string_literal: true

class ReviewsController < ApplicationController
  before_action :set_user_phrase, only: :complete

  def index
    reset_stale_review_flags
    @user_phrases = current_user.user_phrases.pending_review.includes(:phrase)
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
