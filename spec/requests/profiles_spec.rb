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
  end
end
