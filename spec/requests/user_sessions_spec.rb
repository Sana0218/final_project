# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UserSessions', type: :request do
  let(:user) do
    User.create!(
      name: 'Test',
      email: 'session@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
  end

  describe 'GET /login' do
    it 'returns success without authentication' do
      get login_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /login' do
    it 'logs in with valid credentials' do
      post login_path, params: { email: user.email, password: 'password' }

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response).to have_http_status(:success)
    end

    it 'renders login when credentials are invalid' do
      post login_path, params: { email: user.email, password: 'wrong-password' }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'DELETE /logout' do
    it 'logs out the current user' do
      post login_path, params: { email: user.email, password: 'password' }
      delete logout_path

      expect(response).to redirect_to(login_path)
      follow_redirect!
      expect(response.body).to include('ログアウトしました')
      expect(response.body).not_to include('ログインが必要です')

      get profile_path
      expect(response).to redirect_to(login_path)
    end
  end
end
