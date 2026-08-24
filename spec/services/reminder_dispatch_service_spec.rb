# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReminderDispatchService do
  let(:user) do
    User.create!(
      name: 'Test',
      email: 'dispatch@example.com',
      password: 'password',
      password_confirmation: 'password',
      line_user_id: 'U123',
      reminder_enabled: true,
      reminder_hour: 21,
      reminder_minute: 0,
      time_zone: 'Asia/Tokyo'
    )
  end

  before do
    allow(LineBotClient).to receive(:configured?).and_return(true)
    allow(LineReminderService).to receive(:new).and_return(instance_double(LineReminderService, call: true))
    travel_to Time.zone.parse('2026-08-24 21:00:00 +0900')
  end

  it 'sends reminders for users due at the current minute' do
    user
    sent_count = described_class.new.call

    expect(sent_count).to eq(1)
    expect(user.reload.last_reminder_sent_at).to be_present
  end

  it 'does not send reminders outside the configured minute' do
    travel_to Time.zone.parse('2026-08-24 21:05:00 +0900')

    sent_count = described_class.new.call

    expect(sent_count).to eq(0)
    expect(user.reload.last_reminder_sent_at).to be_nil
  end
end
