# frozen_string_literal: true

class AddCorrectionFieldsToDiaries < ActiveRecord::Migration[7.1]
  def change
    change_table :diaries, bulk: true do |t|
      t.text :corrected_text
      t.text :feedback
    end
  end
end
