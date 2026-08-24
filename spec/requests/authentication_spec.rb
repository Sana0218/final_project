# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  let(:user) do
    User.create!(
      name: 'Test',
      email: 'auth@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
  end

  describe 'unauthenticated access' do
    it 'redirects protected pages to login' do
      get diaries_path
      expect(response).to redirect_to(login_path)

      get profile_path
      expect(response).to redirect_to(login_path)

      get reviews_path
      expect(response).to redirect_to(login_path)

      get phrases_path
      expect(response).to redirect_to(login_path)

      get review_calendar_path
      expect(response).to redirect_to(login_path)
    end

    it 'redirects root to login' do
      get root_path
      expect(response).to redirect_to(login_path)
    end

    it 'allows access to registration and login pages' do
      get new_user_path
      expect(response).to have_http_status(:success)

      get login_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'authenticated access' do
    before { post login_path, params: { email: user.email, password: 'password' } }

    it 'allows access to the top page' do
      get root_path
      expect(response).to have_http_status(:success)
    end
  end
end
