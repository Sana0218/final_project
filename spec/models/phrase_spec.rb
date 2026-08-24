# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Phrase, type: :model do
  describe 'validations' do
    it 'is valid with content' do
      phrase = Phrase.new(content: 'It was fun.')
      expect(phrase).to be_valid
    end

    it 'is invalid without content' do
      phrase = Phrase.new(content: nil)
      expect(phrase).not_to be_valid
      expect(phrase.errors[:content]).to be_present
    end
  end
end
