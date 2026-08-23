# frozen_string_literal: true

class ReviewScheduleInitializer
  def initialize(user_phrase)
    @user_phrase = user_phrase
  end

  def call
    return unless @user_phrase.new_record?

    @user_phrase.assign_attributes(
      review_stage: 0,
      next_review_date: Date.current + UserPhrase::REVIEW_STAGES[0],
      review_completed: false
    )
    @user_phrase.save!
  end
end
