class UserPhrase < ApplicationRecord
  belongs_to :user
  belongs_to :phrase

  validates :user_id, uniqueness: { scope: :phrase_id }
end
