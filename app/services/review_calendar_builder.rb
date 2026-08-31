# frozen_string_literal: true

class ReviewCalendarBuilder
  WEEK_START = :sunday

  def self.parse_month(value)
    return Date.current.beginning_of_month if value.blank?

    Date.strptime(value.to_s, '%Y-%m')
  rescue ArgumentError
    Date.current.beginning_of_month
  end

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

  def diary_written_on?(date)
    diary_dates.include?(date)
  end

  private

  def user_phrases
    @user.user_phrases.with_phrase.scheduled_in(@month.all_month)
  end

  def diary_dates
    @diary_dates ||= begin
      zone = user_time_zone
      range = calendar_days.first.in_time_zone(zone).beginning_of_day..calendar_days.last.in_time_zone(zone).end_of_day
      @user.diaries.where(created_at: range).pluck(:created_at).to_set do |time|
        time.in_time_zone(zone).to_date
      end
    end
  end

  def user_time_zone
    ActiveSupport::TimeZone[@user.time_zone] || Time.zone
  end
end
