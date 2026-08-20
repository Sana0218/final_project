class CreateUserPhrases < ActiveRecord::Migration[7.1]
  def change
    create_table :user_phrases do |t|
      t.references :user, null: false, foreign_key: true
      t.references :phrase, null: false, foreign_key: true

      t.timestamps
    end

    add_index :user_phrases, %i[user_id phrase_id], unique: true
  end
end
