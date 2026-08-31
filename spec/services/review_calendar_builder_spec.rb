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

  describe '#diary_written_on?' do
    it 'is true on the local date the user wrote a diary' do
      user.diaries.create!(
        content: 'Wrote in the evening',
        created_at: Time.find_zone('Asia/Tokyo').local(2026, 8, 15, 1, 30, 0)
      )

      calendar = described_class.new(user: user, month: month)

      expect(calendar.diary_written_on?(Date.new(2026, 8, 15))).to be true
      expect(calendar.diary_written_on?(Date.new(2026, 8, 14))).to be false
    end

    it 'does not mark another user\'s diary days' do
      other = User.create!(
        name: 'Other',
        email: 'other-diary-cal@example.com',
        password: 'password',
        password_confirmation: 'password'
      )
      other.diaries.create!(content: 'secret', created_at: Time.utc(2026, 8, 15, 3, 0, 0))

      calendar = described_class.new(user: user, month: month)

      expect(calendar.diary_written_on?(Date.new(2026, 8, 15))).to be false
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
