# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ReviewCalendars', type: :request do
  include_context 'with signed in user'

  describe 'GET /review_calendar' do
    it 'shows the review schedule calendar for the current month' do
      user.user_phrases.create!(
        phrase: Phrase.create!(content: 'go to a shrine'),
        review_stage: 1,
        next_review_date: Date.new(2026, 8, 20)
      )

      travel_to Date.new(2026, 8, 10) do
        get review_calendar_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include('復習スケジュール')
        expect(response.body).to include('2026年8月')
        expect(response.body).to include('go to a shrine')
      end
    end

    it 'shows phrases for the requested month' do
      user.user_phrases.create!(
        phrase: Phrase.create!(content: 'September phrase'),
        review_stage: 0,
        next_review_date: Date.new(2026, 9, 5)
      )

      get review_calendar_path(month: '2026-09')

      expect(response.body).to include('2026年9月')
      expect(response.body).to include('September phrase')
    end

    it 'does not show phrases saved by another user' do
      other = User.create!(
        name: 'Other', email: 'other-calendar@example.com', password: 'password', password_confirmation: 'password'
      )
      other.user_phrases.create!(
        phrase: Phrase.create!(content: 'secret phrase'),
        review_stage: 0,
        next_review_date: Date.current
      )

      get review_calendar_path

      expect(response.body).not_to include('secret phrase')
    end

    it 'falls back to the current month when month param is invalid' do
      travel_to Date.new(2026, 8, 10) do
        get review_calendar_path(month: 'invalid-month')

        expect(response).to have_http_status(:success)
        expect(response.body).to include('2026年8月')
      end
    end
  end
end
