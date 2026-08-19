# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GeminiCorrectionService do
  let(:user) do
    User.create!(name: 'Test', email: 't@example.com', password: 'password', password_confirmation: 'password')
  end
  let(:diary) { user.diaries.create!(content: 'Today I go to park.') }
  let(:client) { instance_double(OpenAI::Client) }

  before do
    payload = { 'corrected_text' => 'Today I went to the park.', 'feedback' => 'go を went に直しました。' }
    allow(OpenAI::Client).to receive(:new).and_return(client)
    allow(client).to receive(:chat)
      .and_return({ 'choices' => [{ 'message' => { 'content' => payload.to_json } }] })
  end

  describe '#call' do
    it 'saves corrected_text and feedback to the diary' do
      described_class.new(diary).call
      diary.reload
      expect(diary.corrected_text).to eq('Today I went to the park.')
      expect(diary.feedback).to eq('go を went に直しました。')
    end

    it 'does not raise when the API request fails' do
      allow(client).to receive(:chat).and_raise(StandardError, 'api error')
      expect { described_class.new(diary).call }.not_to raise_error
      expect(diary.reload.corrected_text).to be_nil
    end
  end
end
