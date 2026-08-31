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

    it 'includes correction feedback in the diary detail payload' do
      user.diaries.create!(
        content: 'I go to park yesterday.',
        corrected_text: 'I went to the park yesterday.',
        feedback: 'go を went に直しました。'
      )

      get diaries_path

      expect(response.body).to include('I go to park yesterday.')
      expect(response.body).to include('I went to the park yesterday.')
      expect(response.body).to include('go を went に直しました。')
      expect(response.body).to include('あなたの文章')
      expect(response.body).to include('フィードバック')
    end
  end
end
