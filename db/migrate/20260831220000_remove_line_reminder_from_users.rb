# frozen_string_literal: true

class RemoveLineReminderFromUsers < ActiveRecord::Migration[7.1]
  def up
    remove_line_reminder_indexes
    remove_line_reminder_columns
  end

  def down
    add_line_reminder_columns
    add_line_reminder_indexes
  end

  private

  def remove_line_reminder_indexes
    remove_index :users, :line_user_id
    remove_index :users, :line_link_token
  end

  def remove_line_reminder_columns
    change_table :users, bulk: true do |t|
      t.remove :line_user_id, type: :string
      t.remove :line_link_token, type: :string
      t.remove :line_link_token_expires_at, type: :datetime
      t.remove :reminder_enabled, type: :boolean, default: false, null: false
      t.remove :reminder_hour, type: :integer, default: 21, null: false
      t.remove :reminder_minute, type: :integer, default: 0, null: false
      t.remove :time_zone, type: :string, default: 'Asia/Tokyo', null: false
      t.remove :last_reminder_sent_at, type: :datetime
    end
  end

  def add_line_reminder_columns
    change_table :users, bulk: true do |t|
      t.string :line_user_id
      t.string :line_link_token
      t.datetime :line_link_token_expires_at
      t.boolean :reminder_enabled, null: false, default: false
      t.integer :reminder_hour, null: false, default: 21
      t.integer :reminder_minute, null: false, default: 0
      t.string :time_zone, null: false, default: 'Asia/Tokyo'
      t.datetime :last_reminder_sent_at
    end
  end

  def add_line_reminder_indexes
    add_index :users, :line_user_id, unique: true, where: 'line_user_id IS NOT NULL'
    add_index :users, :line_link_token, unique: true, where: 'line_link_token IS NOT NULL'
  end
end
