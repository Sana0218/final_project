# frozen_string_literal: true

class ReminderDispatchService
  def call
    return 0 unless LineBotClient.configured?

    sent_count = 0

    User.reminder_configured.find_each do |user|
      next unless user.reminder_due?

      if LineReminderService.new(user).call
        user.update!(last_reminder_sent_at: Time.current)
        sent_count += 1
      end
    end

    sent_count
  end
end
