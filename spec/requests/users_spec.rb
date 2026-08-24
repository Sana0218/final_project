# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'GET /users/new' do
    it 'returns success without authentication' do
      get new_user_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /users' do
    it 'creates a user and redirects to login' do
      post users_path, params: {
        user: {
          name: 'New User',
          email: 'new-user@example.com',
          password: 'password',
          password_confirmation: 'password'
        }
      }

      expect(response).to redirect_to(login_path)
      expect(User.find_by(email: 'new-user@example.com')).to be_present
    end

    it 'renders new when registration fails' do
      post users_path, params: {
        user: {
          name: '',
          email: 'invalid',
          password: 'short',
          password_confirmation: 'different'
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(User.find_by(email: 'invalid')).to be_nil
    end
  end
end
