# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) do
    User.create!(
      name: 'Test',
      email: 'user-model@example.com',
      password: 'password',
      password_confirmation: 'password',
      line_user_id: 'U123',
      reminder_enabled: true,
      reminder_hour: 21,
      reminder_minute: 0,
      time_zone: 'Asia/Tokyo'
    )
  end

  describe '#reminder_due?' do
    it 'returns true at the configured local time' do
      travel_to Time.zone.parse('2026-08-24 21:00:00 +0900') do
        expect(user.reminder_due?).to be(true)
      end
    end

    it 'returns false after reminder was already sent today' do
      travel_to Time.zone.parse('2026-08-24 21:00:00 +0900') do
        user.update!(last_reminder_sent_at: Time.current)
        expect(user.reminder_due?).to be(false)
      end
    end
  end

  describe '#generate_line_link_token!' do
    it 'creates an expiring token' do
      user.generate_line_link_token!

      expect(user.line_link_token).to match(/\A[A-Z0-9]{8}\z/)
      expect(user.line_link_token_expires_at).to be > Time.current
    end
  end
end
