# frozen_string_literal: true

class LineReminderService
  def initialize(user)
    @user = user
  end

  def call
    return false unless deliverable?

    LineBotClient.push_text(@user.line_user_id, build_message)
    true
  rescue Line::Bot::HTTPError => e
    Rails.logger.error("[LineReminderService] push failed for user #{@user.id}: #{e.message}")
    false
  end

  private

  def deliverable?
    @user.reminder_enabled? && @user.line_user_id.present? && LineBotClient.configured?
  end

  def build_message
    pending_count = @user.user_phrases.pending_review.count
    review_url = Rails.application.routes.url_helpers.reviews_url(host: app_host)
    diary_url = Rails.application.routes.url_helpers.new_diary_url(host: app_host)

    <<~MESSAGE.strip
      こんばんは！英語日記の時間です。

      本日の復習: #{pending_count}件
      復習する: #{review_url}
      日記を書く: #{diary_url}
    MESSAGE
  end

  def app_host
    ENV.fetch('APP_HOST', 'localhost:3000')
  end
end
