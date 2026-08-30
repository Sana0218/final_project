# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'StaticPages', type: :request do
  include_context 'with signed in user'

  describe 'GET /' do
    it 'renders the dashboard with a write-diary action and calendar month' do
      travel_to Date.new(2026, 8, 10) do
        get root_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include('日記を書く')
        expect(response.body).to include('2026年8月')
        expect(response.body).to include('作成した日記')
        expect(response.body).to include('保存したフレーズ')
      end
    end

    it 'shows a preview of recent diaries and saved phrases' do
      user.diaries.create!(content: 'Dashboard diary preview')
      user.user_phrases.create!(
        phrase: Phrase.create!(content: 'dashboard phrase'),
        review_stage: 0,
        next_review_date: Date.current
      )

      get root_path

      expect(response.body).to include('Dashboard diary preview')
      expect(response.body).to include('dashboard phrase')
    end

    it 'limits diary previews to the most recent entries' do
      6.times do |index|
        user.diaries.create!(content: "Preview diary #{index}", created_at: index.hours.ago)
      end

      get root_path

      expect(response.body).to include('Preview diary 0')
      expect(response.body).not_to include('Preview diary 5')
    end

    it 'changes the embedded calendar month from the query param' do
      get root_path(month: '2026-09')

      expect(response.body).to include('2026年9月')
    end

    it 'includes desktop icon navigation labels' do
      get root_path

      expect(response.body).to include('aria-label="ホーム"')
      expect(response.body).to include('aria-label="ログアウト"')
    end
  end
end
