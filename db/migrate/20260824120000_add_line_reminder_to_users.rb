# frozen_string_literal: true

class AddLineReminderToUsers < ActiveRecord::Migration[7.1]
  def change
    add_line_reminder_columns
    add_line_reminder_indexes
  end

  private

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
