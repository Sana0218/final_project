# frozen_string_literal: true

FactoryBot.define do
  factory :diary do
    association :user
    content { 'I went to the park today. 今日は公園に行きました。' }
  end
end
