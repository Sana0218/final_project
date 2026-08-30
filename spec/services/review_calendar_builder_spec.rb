# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReviewCalendarBuilder do
  let(:user) do
    User.create!(name: 'Test', email: 'calendar@example.com', password: 'password', password_confirmation: 'password')
  end
  let(:month) { Date.new(2026, 8, 1) }

  describe '.parse_month' do
    it 'returns the beginning of the current month when the value is blank' do
      travel_to Date.new(2026, 8, 10) do
        expect(described_class.parse_month(nil)).to eq(Date.new(2026, 8, 1))
        expect(described_class.parse_month('')).to eq(Date.new(2026, 8, 1))
      end
    end

    it 'parses a year-month string' do
      expect(described_class.parse_month('2026-09')).to eq(Date.new(2026, 9, 1))
    end

    it 'falls back to the current month when the value is invalid' do
      travel_to Date.new(2026, 8, 10) do
        expect(described_class.parse_month('invalid-month')).to eq(Date.new(2026, 8, 1))
      end
    end
  end

  describe '#phrases_for' do
    it 'returns phrases scheduled on the given date' do
      phrase = Phrase.create!(content: 'go to a shrine')
      user.user_phrases.create!(
        phrase: phrase,
        review_stage: 1,
        next_review_date: Date.new(2026, 8, 15)
      )

      calendar = described_class.new(user: user, month: month)

      expect(calendar.phrases_for(Date.new(2026, 8, 15)).map(&:phrase)).to contain_exactly(phrase)
      expect(calendar.phrases_for(Date.new(2026, 8, 16))).to eq([])
    end
  end

  describe '#calendar_days' do
    it 'includes padding days before and after the month' do
      calendar = described_class.new(user: user, month: month)
      days = calendar.calendar_days

      expect(days.first).to eq(Date.new(2026, 7, 26))
      expect(days.last).to eq(Date.new(2026, 9, 5))
      expect(days).to include(Date.new(2026, 8, 1), Date.new(2026, 8, 31))
    end
  end
end
