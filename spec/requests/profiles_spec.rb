# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Profiles', type: :request do
  include_context 'with signed in user'

  describe 'GET /profile' do
    it 'returns http success' do
      get profile_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /profile/edit' do
    it 'returns http success' do
      get edit_profile_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /profile' do
    it 'updates the profile and redirects' do
      patch profile_path, params: { user: { name: 'Updated Name', email: user.email } }
      expect(response).to redirect_to(profile_path)
      expect(user.reload.name).to eq('Updated Name')
    end

    it 'updates reminder settings' do
      patch profile_path, params: {
        user: {
          name: user.name,
          email: user.email,
          reminder_enabled: '1',
          reminder_hour: '20',
          reminder_minute: '30',
          time_zone: 'Asia/Tokyo'
        }
      }

      expect(response).to redirect_to(profile_path)
      expect(user.reload).to have_attributes(
        reminder_enabled: true,
        reminder_hour: 20,
        reminder_minute: 30,
        time_zone: 'Asia/Tokyo'
      )
    end

    it 'renders edit when update fails' do
      patch profile_path, params: { user: { name: user.name, email: 'invalid-email' } }

      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'updates profile without changing password when password is blank' do
      patch profile_path, params: {
        user: {
          name: 'Updated Without Password',
          email: user.email,
          password: '',
          password_confirmation: ''
        }
      }

      expect(response).to redirect_to(profile_path)
      expect(user.reload.name).to eq('Updated Without Password')
    end

    it 'updates password when new password is provided' do
      patch profile_path, params: {
        user: {
          name: user.name,
          email: user.email,
          password: 'newpassword',
          password_confirmation: 'newpassword'
        }
      }

      expect(response).to redirect_to(profile_path)
      expect(user.reload).to be_valid_password('newpassword')
    end
  end

  describe 'POST /profile/line_link_token' do
    it 'generates a LINE link token' do
      post line_link_token_profile_path

      expect(response).to redirect_to(profile_path)
      expect(user.reload.line_link_token).to be_present
      expect(user.line_link_token_expires_at).to be_present
    end
  end
end
