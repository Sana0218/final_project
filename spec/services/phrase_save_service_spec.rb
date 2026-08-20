# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhraseSaveService do
  let(:user) do
    User.create!(name: 'Test', email: 'save@example.com', password: 'password', password_confirmation: 'password')
  end

  describe '#call' do
    it 'creates phrases and user_phrases for the user' do
      contents = ['go to a shrine', 'It was fun.']
      expect { described_class.new(user: user, phrase_contents: contents).call }
        .to change(Phrase, :count).by(2).and change(UserPhrase, :count).by(2)
      expect(user.phrases.pluck(:content)).to match_array(contents)
    end

    it 'reuses an existing phrase record with the same content' do
      Phrase.create!(content: 'go to a shrine')
      expect { described_class.new(user: user, phrase_contents: ['go to a shrine']).call }
        .to change(Phrase, :count).by(0).and change(UserPhrase, :count).by(1)
    end

    it 'does not create duplicate user_phrases for the same phrase' do
      described_class.new(user: user, phrase_contents: ['go to a shrine']).call
      expect { described_class.new(user: user, phrase_contents: ['go to a shrine']).call }
        .not_to change(UserPhrase, :count)
    end

    it 'saves at most 3 phrases' do
      saved = described_class.new(user: user, phrase_contents: %w[one two three four]).call
      expect(saved.size).to eq(3)
      expect(user.phrases.count).to eq(3)
    end

    it 'returns an empty array when no phrase is provided' do
      expect(described_class.new(user: user, phrase_contents: ['', nil]).call).to eq([])
    end
  end
end
