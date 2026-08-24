# frozen_string_literal: true

namespace :reminders do
  desc 'Send LINE reminder notifications to users at their configured routine time'
  task send_line_reminders: :environment do
    sent_count = ReminderDispatchService.new.call
    puts "Sent #{sent_count} LINE reminders"
  end
end
