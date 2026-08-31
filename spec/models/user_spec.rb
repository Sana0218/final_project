# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) do
    User.create!(
      name: 'Test',
      email: 'user-model@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(user).to be_valid
    end

    it 'is invalid without name' do
      user.name = nil
      expect(user).not_to be_valid
      expect(user.errors[:name]).to be_present
    end

    it 'is invalid without email' do
      user.email = nil
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it 'is invalid with a duplicate email' do
      duplicate = User.new(
        name: 'Other',
        email: user.email,
        password: 'password',
        password_confirmation: 'password'
      )
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to be_present
    end

    it 'is invalid with an invalid email format' do
      user.email = 'invalid-email'
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it 'is invalid when password is too short' do
      new_user = User.new(
        name: 'New',
        email: 'new@example.com',
        password: '12345',
        password_confirmation: '12345'
      )
      expect(new_user).not_to be_valid
      expect(new_user.errors[:password]).to be_present
    end

    it 'is invalid when password confirmation does not match' do
      new_user = User.new(
        name: 'New',
        email: 'new@example.com',
        password: 'password',
        password_confirmation: 'different'
      )
      expect(new_user).not_to be_valid
      expect(new_user.errors[:password_confirmation]).to be_present
    end
  end
end
