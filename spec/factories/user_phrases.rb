# frozen_string_literal: true

FactoryBot.define do
  factory :user_phrase do
    association :user
    association :phrase
  end
end
