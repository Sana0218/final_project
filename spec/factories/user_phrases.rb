# frozen_string_literal: true

FactoryBot.define do
  factory :user_phrase do
    association :user
    association :phrase
    review_stage { 0 }
    next_review_date { Date.current + UserPhrase::REVIEW_STAGES[0] }
    review_completed { false }
  end
end
