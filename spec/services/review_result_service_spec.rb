# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReviewResultService do
  let(:user) do
    User.create!(name: 'Test', email: 'result@example.com', password: 'password', password_confirmation: 'password')
  end
  let(:user_phrase) do
    UserPhrase.create!(
      user: user,
      phrase: Phrase.create!(content: 'It was fun.'),
      review_stage: 1,
      next_review_date: Date.new(2026, 8, 20)
    )
  end

  before { travel_to Date.new(2026, 8, 20) }

  it 'advances stage and sets next review date when correct' do
    described_class.new(user_phrase: user_phrase, correct: true).call

    expect(user_phrase.reload).to have_attributes(
      review_stage: 2,
      next_review_date: Date.new(2026, 8, 27),
      review_completed: true
    )
  end

  it 'lowers stage and sets next review date when incorrect' do
    described_class.new(user_phrase: user_phrase, correct: false).call

    expect(user_phrase.reload).to have_attributes(
      review_stage: 0,
      next_review_date: Date.new(2026, 8, 21),
      review_completed: true
    )
  end

  it 'does not exceed max stage when correct' do
    user_phrase.update!(review_stage: UserPhrase::MAX_REVIEW_STAGE)

    described_class.new(user_phrase: user_phrase, correct: true).call

    expect(user_phrase.reload).to have_attributes(
      review_stage: UserPhrase::MAX_REVIEW_STAGE,
      next_review_date: Date.new(2026, 9, 19),
      review_completed: true
    )
  end

  it 'does not drop below stage 0 when incorrect' do
    user_phrase.update!(review_stage: 0)

    described_class.new(user_phrase: user_phrase, correct: false).call

    expect(user_phrase.reload).to have_attributes(
      review_stage: 0,
      next_review_date: Date.new(2026, 8, 21),
      review_completed: true
    )
  end

  it 'advances from stage 0 when correct' do
    user_phrase.update!(review_stage: 0)

    described_class.new(user_phrase: user_phrase, correct: true).call

    expect(user_phrase.reload).to have_attributes(
      review_stage: 1,
      next_review_date: Date.new(2026, 8, 23),
      review_completed: true
    )
  end
end
