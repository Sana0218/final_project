# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GeminiCorrectionService do
  let(:user) do
    User.create!(name: 'Test', email: 't@example.com', password: 'password', password_confirmation: 'password')
  end
  let(:diary) { user.diaries.create!(content: 'Today I go to park.') }
  let(:client) { instance_double(OpenAI::Client) }

  before do
    payload = {
      'corrected_text' => 'Today I went to the park.',
      'feedback' => 'go を went に直しました。',
      'suggested_phrases' => ['go to the park', 'It was fun.', 'have a great day']
    }
    allow(OpenAI::Client).to receive(:new).and_return(client)
    allow(client).to receive(:chat)
      .and_return({ 'choices' => [{ 'message' => { 'content' => payload.to_json } }] })
  end

  describe '#call' do
    it 'saves corrected_text, feedback, and suggested_phrases to the diary' do
      described_class.new(diary).call
      expect(diary.reload).to have_attributes(
        corrected_text: 'Today I went to the park.',
        feedback: 'go を went に直しました。',
        suggested_phrases: ['go to the park', 'It was fun.', 'have a great day']
      )
    end

    it 'does not raise when the API request fails' do
      allow(client).to receive(:chat).and_raise(StandardError, 'api error')
      expect { described_class.new(diary).call }.not_to raise_error
      expect(diary.reload.corrected_text).to be_nil
    end

    it 'sends practice phrases with the learner writing' do
      described_class.new(diary, practice_phrases: ['go to a shrine']).call

      expect(client).to have_received(:chat) do |args|
        messages = args[:parameters][:messages]
        expect(messages.first[:content]).to include('practicing target English')
        expect(messages.last[:content]).to include('go to a shrine')
        expect(messages.last[:content]).to include(diary.content)
      end
    end
  end
end
