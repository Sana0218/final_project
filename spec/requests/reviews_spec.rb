# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Reviews', type: :request do
  include_context 'with signed in user'

  let(:phrase) { Phrase.create!(content: 'go to a shrine') }

  describe 'GET /reviews' do
    it 'lists phrases due for review today' do
      user.user_phrases.create!(
        phrase: phrase,
        review_stage: 1,
        next_review_date: Date.current,
        review_completed: false
      )

      get reviews_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('go to a shrine')
      expect(response.body).to include('本日の復習')
      expect(response.body).to include('フレーズを使って書いてみる')
    end

    it 'does not list phrases scheduled for a future review date' do
      user.user_phrases.create!(
        phrase: phrase,
        review_stage: 2,
        next_review_date: Date.current + 7.days,
        review_completed: false
      )

      get reviews_path

      expect(response.body).not_to include('go to a shrine')
    end

    it 'resets review_completed for due phrases and shows them again' do
      user.user_phrases.create!(
        phrase: phrase,
        review_stage: 1,
        next_review_date: Date.current,
        review_completed: true
      )

      get reviews_path

      expect(response.body).to include('go to a shrine')
    end
  end

  describe 'POST /reviews/:id/complete' do
    let(:user_phrase) do
      user.user_phrases.create!(
        phrase: phrase,
        review_stage: 1,
        next_review_date: Date.current,
        review_completed: false
      )
    end

    before { travel_to Date.new(2026, 8, 20) }

    it 'records a correct review and updates the schedule' do
      post complete_review_path(user_phrase), params: { correct: true }

      expect(response).to redirect_to(reviews_path)
      follow_redirect!
      expect(response.body).to include('復習を記録しました')
      expect(user_phrase.reload).to have_attributes(
        review_stage: 2,
        next_review_date: Date.new(2026, 8, 27),
        review_completed: true
      )
    end

    it 'records an incorrect review and updates the schedule' do
      post complete_review_path(user_phrase), params: { correct: false }

      expect(user_phrase.reload).to have_attributes(
        review_stage: 0,
        next_review_date: Date.new(2026, 8, 21),
        review_completed: true
      )
    end

    it 'rejects review for phrases not due today' do
      user_phrase.update!(next_review_date: Date.current + 3.days)

      post complete_review_path(user_phrase), params: { correct: true }

      expect(response).to redirect_to(reviews_path)
      follow_redirect!
      expect(response.body).to include('本日の復習対象ではありません')
    end

    it 'returns not found for another users phrase' do
      other = User.create!(
        name: 'Other', email: 'other-review@example.com', password: 'password', password_confirmation: 'password'
      )
      other_phrase = other.user_phrases.create!(
        phrase: Phrase.create!(content: 'secret phrase'),
        review_stage: 0,
        next_review_date: Date.current
      )

      post complete_review_path(other_phrase), params: { correct: true }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /reviews' do
    let!(:user_phrase) do
      user.user_phrases.create!(
        phrase: phrase,
        review_stage: 1,
        next_review_date: Date.current,
        review_completed: false
      )
    end

    it 'corrects a sentence that uses review phrases' do
      service = instance_double(GeminiCorrectionService, call: true)
      allow(GeminiCorrectionService).to receive(:new) do |diary, **|
        diary.update!(
          corrected_text: 'Yesterday I went to a shrine.',
          feedback: '時制を過去形に直しました。'
        )
        service
      end

      expect do
        post reviews_path, params: { review_writing: { content: 'Yesterday I go to a shrine.' } }
      end.to change(Diary, :count).by(1)

      diary = Diary.last
      expect(GeminiCorrectionService).to have_received(:new)
        .with(diary, practice_phrases: ['go to a shrine'])
      expect(service).to have_received(:call)
      expect(response).to redirect_to(reviews_path(writing_id: diary.id))
      follow_redirect!
      expect(response.body).to include('添削が完了しました')
      expect(response.body).to include('Yesterday I go to a shrine.')
      expect(response.body).to include('Yesterday I went to a shrine.')
      expect(response.body).to include('時制を過去形に直しました。')
    end

    it 'redirects with an alert when AI correction fails' do
      service = instance_double(GeminiCorrectionService, call: false)
      allow(GeminiCorrectionService).to receive(:new).and_return(service)

      post reviews_path, params: { review_writing: { content: 'Yesterday I go to a shrine.' } }

      diary = Diary.last
      expect(response).to redirect_to(reviews_path(writing_id: diary.id))
      follow_redirect!
      expect(response.body).to include('AI添削に失敗しました')
      expect(response.body).to include('Yesterday I go to a shrine.')
    end

    it 'rejects blank writing' do
      expect do
        post reviews_path, params: { review_writing: { content: '' } }
      end.not_to change(Diary, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('文章の投稿に失敗しました')
    end
  end
end
