# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'LineWebhooks', type: :request do
  let(:body) do
    {
      events: [
        {
          type: 'message',
          replyToken: 'reply-token',
          source: { userId: 'U123' },
          message: { type: 'text', text: 'ABCD1234' }
        }
      ]
    }.to_json
  end

  before do
    allow(LineBotClient).to receive(:configured?).and_return(true)
    allow(LineBotClient).to receive(:validate_signature).and_return(true)
    allow(LineBotClient).to receive(:reply_text)
    User.create!(
      name: 'Test',
      email: 'webhook@example.com',
      password: 'password',
      password_confirmation: 'password',
      line_link_token: 'ABCD1234',
      line_link_token_expires_at: 1.hour.from_now
    )
  end

  it 'accepts a valid webhook and links the LINE account' do
    post '/line/webhook', params: body, headers: { 'CONTENT_TYPE' => 'application/json' }

    expect(response).to have_http_status(:ok)
    expect(User.find_by(email: 'webhook@example.com').line_user_id).to eq('U123')
    expect(LineBotClient).to have_received(:reply_text).with('reply-token', a_string_including('完了'))
  end

  it 'returns service unavailable when LINE is not configured' do
    allow(LineBotClient).to receive(:configured?).and_return(false)

    post '/line/webhook', params: body, headers: { 'CONTENT_TYPE' => 'application/json' }

    expect(response).to have_http_status(:service_unavailable)
  end

  it 'returns bad request when signature validation fails' do
    allow(LineBotClient).to receive(:validate_signature).and_return(false)

    post '/line/webhook', params: body, headers: { 'CONTENT_TYPE' => 'application/json' }

    expect(response).to have_http_status(:bad_request)
  end

  it 'replies with a welcome message on follow events' do
    follow_body = {
      events: [
        {
          type: 'follow',
          replyToken: 'follow-reply-token',
          source: { userId: 'U456' }
        }
      ]
    }.to_json

    post '/line/webhook', params: follow_body, headers: { 'CONTENT_TYPE' => 'application/json' }

    expect(response).to have_http_status(:ok)
    expect(LineBotClient).to have_received(:reply_text).with('follow-reply-token', a_string_including('ようこそ'))
  end
end
