# frozen_string_literal: true

class UserPhrase < ApplicationRecord
  belongs_to :user
  belongs_to :phrase

  validates :user_id, uniqueness: { scope: :phrase_id }

  REVIEW_STAGES = {
    0 => 1,
    1 => 3,
    2 => 7,
    3 => 14,
    4 => 30
  }.freeze

  MAX_REVIEW_STAGE = REVIEW_STAGES.keys.max

  validates :review_stage,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: MAX_REVIEW_STAGE
            }
  validates :next_review_date, presence: true

  scope :due_for_review, ->(date = Date.current) { where(next_review_date: ..date) }
  scope :pending_review, ->(date = Date.current) { due_for_review(date).where(review_completed: false) }
  scope :with_phrase, -> { includes(:phrase) }

  def due_for_review?(date = Date.current)
    next_review_date <= date
  end
end
