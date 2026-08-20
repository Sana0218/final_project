class CreatePhrases < ActiveRecord::Migration[7.1]
  def change
    create_table :phrases do |t|
      t.string :content, null: false

      t.timestamps
    end
  end
end
