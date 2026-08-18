# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Diaries::Show', type: :request do
  include_context 'with signed in user'

  describe 'GET /diaries/:id' do
    it 'returns diary detail for the current user' do
      diary = user.diaries.create!(content: 'Detailed diary content.')
      get diary_path(diary)
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Detailed diary content.')
    end

    it 'returns not found for another users diary' do
      other = User.create!(
        name: 'Other', email: 'other@example.com', password: 'password', password_confirmation: 'password'
      )
      diary = other.diaries.create!(content: 'Private diary.')
      get diary_path(diary)
      expect(response).to have_http_status(:not_found)
    end
  end
end
