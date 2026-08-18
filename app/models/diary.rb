# frozen_string_literal: true

class Diary < ApplicationRecord
  belongs_to :user

  validates :content, presence: true, length: { maximum: 10_000 }
end
