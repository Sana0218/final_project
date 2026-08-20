# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Diaries::SavePhrases', type: :request do
  include_context 'with signed in user'

  describe 'POST /diaries/:id/save_phrases' do
    let(:diary) do
      user.diaries.create!(
        content: 'Today I went to a shrine.',
        corrected_text: 'Today I went to a shrine.',
        feedback: 'Good job.',
        suggested_phrases: ['go to a shrine', 'It was fun.', 'have a great time']
      )
    end

    it 'saves selected phrases for the current user' do
      expect do
        post save_phrases_diary_path(diary), params: { phrase_contents: ['go to a shrine', 'It was fun.'] }
      end.to change(Phrase, :count).by(2).and change(UserPhrase, :count).by(2)
      expect(response).to redirect_to(diary_path(diary))
      follow_redirect!
      expect(response.body).to include('2件のフレーズを保存しました')
    end

    it 'redirects with alert when no phrase is selected' do
      post save_phrases_diary_path(diary), params: { phrase_contents: [] }
      expect(response).to redirect_to(diary_path(diary))
      follow_redirect!
      expect(response.body).to include('保存するフレーズを選択してください')
    end

    it 'returns not found for another users diary' do
      other_diary = User.create!(
        name: 'Other', email: 'other-save@example.com', password: 'password', password_confirmation: 'password'
      ).diaries.create!(content: 'Private diary.', suggested_phrases: ['secret phrase'])
      post save_phrases_diary_path(other_diary), params: { phrase_contents: ['secret phrase'] }
      expect(response).to have_http_status(:not_found)
    end
  end
end
