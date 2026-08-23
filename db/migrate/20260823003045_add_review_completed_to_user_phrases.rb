# frozen_string_literal: true

class AddReviewCompletedToUserPhrases < ActiveRecord::Migration[7.1]
  def change
    add_column :user_phrases, :review_completed, :boolean, null: false, default: false
  end
end
