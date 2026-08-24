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

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(user).to be_valid
    end

    it 'is invalid without name' do
      user.name = nil
      expect(user).not_to be_valid
      expect(user.errors[:name]).to be_present
    end

    it 'is invalid without email' do
      user.email = nil
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it 'is invalid with a duplicate email' do
      duplicate = User.new(
        name: 'Other',
        email: user.email,
        password: 'password',
        password_confirmation: 'password'
      )
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to be_present
    end

    it 'is invalid with an invalid email format' do
      user.email = 'invalid-email'
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it 'is invalid when password is too short' do
      new_user = User.new(
        name: 'New',
        email: 'new@example.com',
        password: '12345',
        password_confirmation: '12345'
      )
      expect(new_user).not_to be_valid
      expect(new_user.errors[:password]).to be_present
    end

    it 'is invalid when password confirmation does not match' do
      new_user = User.new(
        name: 'New',
        email: 'new@example.com',
        password: 'password',
        password_confirmation: 'different'
      )
      expect(new_user).not_to be_valid
      expect(new_user.errors[:password_confirmation]).to be_present
    end

    it 'is invalid when reminder_hour is out of range' do
      user.reminder_hour = 24
      expect(user).not_to be_valid
      expect(user.errors[:reminder_hour]).to be_present
    end

    it 'is invalid when reminder_minute is out of range' do
      user.reminder_minute = 60
      expect(user).not_to be_valid
      expect(user.errors[:reminder_minute]).to be_present
    end

    it 'is invalid with an unsupported time zone' do
      user.time_zone = 'America/New_York'
      expect(user).not_to be_valid
      expect(user.errors[:time_zone]).to be_present
    end
  end

  describe '.reminder_configured' do
    it 'returns users with reminders enabled and LINE linked' do
      expect(User.reminder_configured).to contain_exactly(user)
    end

    it 'excludes users without LINE linkage' do
      user.update!(line_user_id: nil)
      expect(User.reminder_configured).to be_empty
    end
  end

  describe '#line_linked?' do
    it 'returns true when line_user_id is present' do
      expect(user.line_linked?).to be(true)
    end

    it 'returns false when line_user_id is blank' do
      user.line_user_id = nil
      expect(user.line_linked?).to be(false)
    end
  end

  describe '#link_token_valid?' do
    it 'returns true for a non-expired token' do
      user.update!(line_link_token: 'ABCD1234', line_link_token_expires_at: 1.hour.from_now)
      expect(user.link_token_valid?).to be(true)
    end

    it 'returns false for an expired token' do
      user.update!(line_link_token: 'ABCD1234', line_link_token_expires_at: 1.hour.ago)
      expect(user.link_token_valid?).to be(false)
    end
  end

  describe '#reminder_time_label' do
    it 'returns the configured time in HH:MM format' do
      expect(user.reminder_time_label).to eq('21:00')
    end
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
