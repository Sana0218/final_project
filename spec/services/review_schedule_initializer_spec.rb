# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReviewScheduleInitializer do
  let(:user) do
    User.create!(name: 'Test', email: 'init@example.com', password: 'password', password_confirmation: 'password')
  end
  let(:phrase) { Phrase.create!(content: 'go to a shrine') }

  before { travel_to Date.new(2026, 8, 20) }

  after { travel_back }

  it 'sets initial review schedule for a new user_phrase' do
    user_phrase = user.user_phrases.build(phrase: phrase)

    described_class.new(user_phrase).call

    expect(user_phrase.reload).to have_attributes(
      review_stage: 0,
      next_review_date: Date.new(2026, 8, 21)
    )
  end

  it 'does not change schedule for an existing user_phrase' do
    user_phrase = user.user_phrases.create!(
      phrase: phrase, review_stage: 2, next_review_date: Date.new(2026, 9, 1)
    )

    expect { described_class.new(user_phrase).call }
      .not_to(change { user_phrase.reload.attributes.slice('review_stage', 'next_review_date') })
  end
end
