# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_context 'with signed in user' do
  let(:user) do
    User.create!(name: 'Test', email: 'test@example.com', password: 'password', password_confirmation: 'password')
  end

  before { post login_path, params: { email: user.email, password: 'password' } }
end

RSpec.describe 'Diaries', type: :request do
  include_context 'with signed in user'

  describe 'GET /diaries' do
    it 'returns success and lists diaries' do
      diary = user.diaries.create!(content: 'My first diary entry.')
      get diaries_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include(diary.content)
    end
  end

  describe 'POST /diaries' do
    it 'creates a diary and redirects to index' do
      expect do
        post diaries_path, params: { diary: { content: 'Today was a good day.' } }
      end.to change(Diary, :count).by(1)

      expect(response).to redirect_to(diaries_path)
      follow_redirect!
      expect(response.body).to include('Today was a good day.')
    end

    it 'rejects invalid params' do
      expect do
        post diaries_path, params: { diary: { content: '' } }
      end.not_to change(Diary, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
