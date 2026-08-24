# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LineBotClient do
  let(:line_client) { instance_double('LineClient', push_message: true, reply_message: true, validate_signature: true) }
  let(:client_class) { Class.new }

  before do
    stub_const('Line::Bot::Client', client_class)
    allow(client_class).to receive(:new) do |&block|
      if block
        config = Struct.new(:channel_secret, :channel_token, keyword_init: true).new
        block.call(config)
      end
      line_client
    end
    LineBotClient.remove_instance_variable(:@client) if LineBotClient.instance_variable_defined?(:@client)
  end

  after do
    LineBotClient.remove_instance_variable(:@client) if LineBotClient.instance_variable_defined?(:@client)
  end

  describe '.configured?' do
    it 'returns true when both env vars are present' do
      ENV['LINE_CHANNEL_SECRET'] = 'secret'
      ENV['LINE_CHANNEL_ACCESS_TOKEN'] = 'token'

      expect(LineBotClient.configured?).to be(true)
    end

    it 'returns false when env vars are missing' do
      ENV.delete('LINE_CHANNEL_SECRET')
      ENV.delete('LINE_CHANNEL_ACCESS_TOKEN')

      expect(LineBotClient.configured?).to be(false)
    end
  end

  describe '.push_text' do
    before do
      ENV['LINE_CHANNEL_SECRET'] = 'secret'
      ENV['LINE_CHANNEL_ACCESS_TOKEN'] = 'token'
      allow(line_client).to receive(:push_message)
    end

    it 'pushes a text message to the LINE user' do
      LineBotClient.push_text('U123', 'hello')

      expect(line_client).to have_received(:push_message).with('U123', { type: 'text', text: 'hello' })
    end

    it 'configures the LINE client with credentials from the environment' do
      config = nil
      allow(client_class).to receive(:new) do |&block|
        config = Struct.new(:channel_secret, :channel_token, keyword_init: true).new
        block&.call(config)
        line_client
      end
      LineBotClient.remove_instance_variable(:@client) if LineBotClient.instance_variable_defined?(:@client)

      LineBotClient.push_text('U123', 'hello')

      expect(config.channel_secret).to eq('secret')
      expect(config.channel_token).to eq('token')
    end
  end

  describe '.reply_text' do
    before do
      ENV['LINE_CHANNEL_SECRET'] = 'secret'
      ENV['LINE_CHANNEL_ACCESS_TOKEN'] = 'token'
      allow(line_client).to receive(:reply_message)
    end

    it 'replies with a text message' do
      LineBotClient.reply_text('reply-token', 'welcome')

      expect(line_client).to have_received(:reply_message).with('reply-token', { type: 'text', text: 'welcome' })
    end
  end

  describe '.validate_signature' do
    it 'returns false when LINE is not configured' do
      ENV.delete('LINE_CHANNEL_SECRET')
      ENV.delete('LINE_CHANNEL_ACCESS_TOKEN')

      expect(LineBotClient.validate_signature('body', 'signature')).to be(false)
    end

    it 'delegates validation to the LINE client when configured' do
      ENV['LINE_CHANNEL_SECRET'] = 'secret'
      ENV['LINE_CHANNEL_ACCESS_TOKEN'] = 'token'
      allow(line_client).to receive(:validate_signature).and_return(true)

      expect(LineBotClient.validate_signature('body', 'signature')).to be(true)
      expect(line_client).to have_received(:validate_signature).with('body', 'signature')
    end
  end
end
