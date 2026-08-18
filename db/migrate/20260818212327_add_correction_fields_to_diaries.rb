class AddCorrectionFieldsToDiaries < ActiveRecord::Migration[7.1]
  def change
    add_column :diaries, :corrected_text, :text
    add_column :diaries, :feedback, :text
  end
end
