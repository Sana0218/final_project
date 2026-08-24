# frozen_string_literal: true

class LineBotClient
  class ConfigurationError < StandardError; end

  def self.client
    return nil unless configured?

    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV.fetch('LINE_CHANNEL_SECRET')
      config.channel_token = ENV.fetch('LINE_CHANNEL_ACCESS_TOKEN')
    end
  end

  def self.configured?
    ENV['LINE_CHANNEL_SECRET'].present? && ENV['LINE_CHANNEL_ACCESS_TOKEN'].present?
  end

  def self.push_text(line_user_id, text)
    client.push_message(line_user_id, { type: 'text', text: text })
  end

  def self.reply_text(reply_token, text)
    client.reply_message(reply_token, { type: 'text', text: text })
  end

  def self.validate_signature(body, signature)
    return false unless configured?

    client.validate_signature(body, signature)
  end
end
