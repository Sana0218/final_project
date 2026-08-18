# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Diaries', type: :request do
  include_context 'with signed in user'

  describe 'GET /diaries' do
    it 'returns success and lists diaries' do
      diary = user.diaries.create!(content: 'My first diary entry.')
      get diaries_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include(diary.content)
      expect(response.body).to include('詳細を見る')
    end
  end
end
