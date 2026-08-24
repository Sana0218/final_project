# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Diaries::New', type: :request do
  include_context 'with signed in user'

  describe 'GET /diaries/new' do
    it 'returns success' do
      get new_diary_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('日記')
    end
  end
end
