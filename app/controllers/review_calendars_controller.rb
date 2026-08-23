# frozen_string_literal: true

class ReviewCalendarsController < ApplicationController
  def show
    @calendar = ReviewCalendarBuilder.new(user: current_user, month: parse_month(params[:month]))
  end

  private

  def parse_month(value)
    return Date.current.beginning_of_month if value.blank?

    Date.strptime(value, '%Y-%m')
  rescue ArgumentError
    Date.current.beginning_of_month
  end
end
