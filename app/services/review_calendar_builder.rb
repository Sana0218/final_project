# frozen_string_literal: true

class ReviewCalendarBuilder
  WEEK_START = :sunday

  def initialize(user:, month:)
    @user = user
    @month = month.beginning_of_month
  end

  attr_reader :month

  def phrases_by_date
    @phrases_by_date ||= user_phrases.group_by(&:next_review_date)
  end

  def calendar_days
    start_date = @month.beginning_of_week(WEEK_START)
    end_date = @month.end_of_month.end_of_week(WEEK_START)
    (start_date..end_date).to_a
  end

  def phrases_for(date)
    phrases_by_date[date] || []
  end

  def current_month?(date)
    date.month == @month.month
  end

  private

  def user_phrases
    @user.user_phrases.with_phrase.scheduled_in(@month.all_month)
  end
end
