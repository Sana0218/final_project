# frozen_string_literal: true

class Diary < ApplicationRecord
  belongs_to :user

  scope :ordered, -> { order(created_at: :desc) }

  validates :content, presence: true, length: { maximum: 10_000 }
end
