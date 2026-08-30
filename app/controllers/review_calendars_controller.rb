# frozen_string_literal: true

class ReviewCalendarsController < ApplicationController
  def show
    @calendar = ReviewCalendarBuilder.new(user: current_user, month: ReviewCalendarBuilder.parse_month(params[:month]))
  end
end
