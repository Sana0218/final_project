# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Diaries::Create', type: :request do
  include_context 'with signed in user'

  describe 'POST /diaries' do
    it 'creates a diary and redirects to the detail page' do
      service = instance_double(GeminiCorrectionService, call: { corrected_text: 'Fixed.', feedback: 'OK' })
      allow(GeminiCorrectionService).to receive(:new).and_return(service)

      expect { post diaries_path, params: { diary: { content: 'Today was a good day.' } } }
        .to change(Diary, :count).by(1)

      diary = Diary.last
      expect(response).to redirect_to(diary_path(diary))
      expect(diary).to have_attributes(corrected_text: 'Fixed.', feedback: 'OK')
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
