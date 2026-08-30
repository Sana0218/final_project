# frozen_string_literal: true

class StaticPagesController < ApplicationController
  DASHBOARD_PREVIEW_LIMIT = 5

  def top
    @calendar = ReviewCalendarBuilder.new(
      user: current_user,
      month: ReviewCalendarBuilder.parse_month(params[:month])
    )
    @recent_diaries = current_user.diaries.ordered.limit(DASHBOARD_PREVIEW_LIMIT)
    @recent_user_phrases = current_user.user_phrases.with_phrase.recent.limit(DASHBOARD_PREVIEW_LIMIT)
  end
end
