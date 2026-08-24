# frozen_string_literal: true

class LineWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :require_login

  def create
    return head(:service_unavailable) unless LineBotClient.configured?
    return head(:bad_request) unless valid_signature?

    JSON.parse(request.raw_post)['events']&.each { |event| handle_event(event) }

    head :ok
  end

  private

  def valid_signature?
    LineBotClient.validate_signature(request.raw_post, request.env['HTTP_X_LINE_SIGNATURE'])
  end

  def handle_event(event)
    case event['type']
    when 'message'
      handle_message_event(event)
    when 'follow'
      handle_follow_event(event)
    end
  end

  def handle_message_event(event)
    return unless event.dig('message', 'type') == 'text'

    line_user_id = event['source']['userId']
    text = event.dig('message', 'text')
    result = LineAccountLinkService.new(line_user_id: line_user_id, token: text).call
    LineBotClient.reply_text(event['replyToken'], result[:message])
  end

  def handle_follow_event(event)
    message = <<~TEXT.strip
      英語日記アプリへようこそ。
      アプリのマイページで連携コードを発行し、そのコードをこのトークに送ってください。
    TEXT
    LineBotClient.reply_text(event['replyToken'], message)
  end
end
