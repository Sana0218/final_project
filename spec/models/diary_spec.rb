# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Diary, type: :model do
  let(:user) do
    User.create!(name: 'Test', email: 'test@example.com', password: 'password', password_confirmation: 'password')
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      diary = Diary.new(user: user, content: 'Today was a good day.')
      expect(diary).to be_valid
    end

    it 'is invalid without content' do
      diary = Diary.new(user: user, content: nil)
      expect(diary).not_to be_valid
    end

    it 'is invalid without user' do
      diary = Diary.new(content: 'Today was a good day.')
      expect(diary).not_to be_valid
    end

    it 'is invalid when content exceeds maximum length' do
      diary = Diary.new(user: user, content: 'a' * 10_001)
      expect(diary).not_to be_valid
    end
  end
end
