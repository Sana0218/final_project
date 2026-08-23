# frozen_string_literal: true

class ReviewResultService
  def initialize(user_phrase:, correct:)
    @user_phrase = user_phrase
    @correct = correct
  end

  def call
    new_stage = calculate_stage

    @user_phrase.update!(
      review_stage: new_stage,
      next_review_date: Date.current + UserPhrase::REVIEW_STAGES[new_stage]
    )
  end

  private

  def calculate_stage
    if @correct
      [@user_phrase.review_stage + 1, UserPhrase::MAX_REVIEW_STAGE].min
    else
      [@user_phrase.review_stage - 1, 0].max
    end
  end
end
