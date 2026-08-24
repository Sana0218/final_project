# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPhrase, type: :model do
  let(:user) do
    User.create!(
      name: 'Test',
      email: 'user-phrase@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
  end
  let(:phrase) { Phrase.create!(content: 'It was fun.') }

  describe 'validations' do
    it 'is valid with required attributes' do
      user_phrase = UserPhrase.new(
        user: user,
        phrase: phrase,
        review_stage: 0,
        next_review_date: Date.current
      )
      expect(user_phrase).to be_valid
    end

    it 'is invalid without next_review_date' do
      user_phrase = UserPhrase.new(user: user, phrase: phrase, review_stage: 0, next_review_date: nil)
      expect(user_phrase).not_to be_valid
      expect(user_phrase.errors[:next_review_date]).to be_present
    end

    it 'is invalid when review_stage is out of range' do
      user_phrase = UserPhrase.new(
        user: user,
        phrase: phrase,
        review_stage: UserPhrase::MAX_REVIEW_STAGE + 1,
        next_review_date: Date.current
      )
      expect(user_phrase).not_to be_valid
      expect(user_phrase.errors[:review_stage]).to be_present
    end

    it 'enforces uniqueness of phrase per user' do
      UserPhrase.create!(user: user, phrase: phrase, review_stage: 0, next_review_date: Date.current)
      duplicate = UserPhrase.new(user: user, phrase: phrase, review_stage: 0, next_review_date: Date.current)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to be_present
    end
  end

  describe 'scopes' do
    let!(:due_phrase) do
      UserPhrase.create!(
        user: user,
        phrase: Phrase.create!(content: 'Due phrase.'),
        review_stage: 0,
        next_review_date: Date.new(2026, 8, 20),
        review_completed: false
      )
    end
    let!(:future_phrase) do
      UserPhrase.create!(
        user: user,
        phrase: Phrase.create!(content: 'Future phrase.'),
        review_stage: 1,
        next_review_date: Date.new(2026, 8, 25),
        review_completed: false
      )
    end
    let!(:completed_phrase) do
      UserPhrase.create!(
        user: user,
        phrase: Phrase.create!(content: 'Completed phrase.'),
        review_stage: 0,
        next_review_date: Date.new(2026, 8, 20),
        review_completed: true
      )
    end

    before { travel_to Date.new(2026, 8, 20) }

    it 'returns phrases due for review on or before the given date' do
      expect(UserPhrase.due_for_review).to contain_exactly(due_phrase, completed_phrase)
    end

    it 'returns only incomplete phrases due for review' do
      expect(UserPhrase.pending_review).to contain_exactly(due_phrase)
    end

    it 'returns phrases scheduled within the given range' do
      range = Date.new(2026, 8, 20)..Date.new(2026, 8, 25)
      expect(UserPhrase.scheduled_in(range)).to contain_exactly(due_phrase, future_phrase, completed_phrase)
    end
  end

  describe '#due_for_review?' do
    let(:user_phrase) do
      UserPhrase.create!(
        user: user,
        phrase: phrase,
        review_stage: 0,
        next_review_date: Date.new(2026, 8, 20)
      )
    end

    it 'returns true when next_review_date is on or before the given date' do
      expect(user_phrase.due_for_review?(Date.new(2026, 8, 20))).to be(true)
      expect(user_phrase.due_for_review?(Date.new(2026, 8, 21))).to be(true)
    end

    it 'returns false when next_review_date is after the given date' do
      expect(user_phrase.due_for_review?(Date.new(2026, 8, 19))).to be(false)
    end
  end
end
