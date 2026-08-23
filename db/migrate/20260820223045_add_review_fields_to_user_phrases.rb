# frozen_string_literal: true

class AddReviewFieldsToUserPhrases < ActiveRecord::Migration[7.1]
  def change
    change_table :user_phrases, bulk: true do |t|
      t.integer :review_stage, null: false, default: 0
      t.date :next_review_date, null: false, default: -> { 'CURRENT_DATE' }
      t.index %i[user_id next_review_date]
    end
  end
end
