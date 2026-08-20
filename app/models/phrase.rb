# frozen_string_literal: true

class Phrase < ApplicationRecord
  has_many :user_phrases, dependent: :destroy
  has_many :users, through: :user_phrases

  validates :content, presence: true
end
