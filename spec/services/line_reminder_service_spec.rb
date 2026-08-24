# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LineReminderService do
  let(:user) do
    User.create!(
      name: 'Test',
      email: 'line-reminder@example.com',
      password: 'password',
      password_confirmation: 'password',
      line_user_id: 'U123',
      reminder_enabled: true
    )
  end

  before do
    allow(LineBotClient).to receive(:configured?).and_return(true)
    allow(LineBotClient).to receive(:push_text)
  end

  let(:phrase) { Phrase.create!(content: 'It was fun.') }

  it 'pushes a reminder message when deliverable' do
    UserPhrase.create!(
      user: user,
      phrase: phrase,
      review_stage: 0,
      next_review_date: Date.current,
      review_completed: false
    )

    result = described_class.new(user).call

    expect(result).to be(true)
    expect(LineBotClient).to have_received(:push_text).with('U123', a_string_including('本日の復習: 1件'))
  end

  it 'does not push when reminder is disabled' do
    user.update!(reminder_enabled: false)

    result = described_class.new(user).call

    expect(result).to be(false)
    expect(LineBotClient).not_to have_received(:push_text)
  end

  it 'returns false when LINE push fails' do
    http_error = Class.new(StandardError)
    stub_const('Line::Bot::HTTPError', http_error)
    allow(LineBotClient).to receive(:push_text).and_raise(http_error.new('push failed'))

    result = described_class.new(user).call

    expect(result).to be(false)
  end
end
