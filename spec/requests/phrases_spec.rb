# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Phrases', type: :request do
  include_context 'with signed in user'

  describe 'GET /phrases' do
    it 'lists saved phrases for the current user' do
      phrase = Phrase.create!(content: 'go to a shrine')
      user.user_phrases.create!(
        phrase: phrase,
        review_stage: 1,
        next_review_date: Date.current + 3.days
      )

      get phrases_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('保存済みフレーズ')
      expect(response.body).to include('go to a shrine')
      expect(response.body).to include('復習ステージ')
    end

    it 'does not list phrases saved by another user' do
      other = User.create!(
        name: 'Other', email: 'other-phrase@example.com', password: 'password', password_confirmation: 'password'
      )
      other.user_phrases.create!(
        phrase: Phrase.create!(content: 'secret phrase'),
        review_stage: 0,
        next_review_date: Date.current + 1.day
      )

      get phrases_path

      expect(response.body).not_to include('secret phrase')
    end

    it 'shows empty state when no phrase is saved' do
      get phrases_path

      expect(response.body).to include('保存済みのフレーズはまだありません')
    end
  end
end
