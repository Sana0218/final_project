# frozen_string_literal: true

class AddSuggestedPhrasesToDiaries < ActiveRecord::Migration[7.1]
  def change
    add_column :diaries, :suggested_phrases, :jsonb, default: [], null: false
  end
end
