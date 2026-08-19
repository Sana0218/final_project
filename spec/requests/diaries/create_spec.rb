# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Diaries::Create', type: :request do
  include_context 'with signed in user'

  describe 'POST /diaries' do
    it 'creates a diary and redirects to the detail page' do
      service = instance_double(GeminiCorrectionService, call: true)
      allow(GeminiCorrectionService).to receive(:new).and_return(service)

      expect { post diaries_path, params: { diary: { content: 'Today was a good day.' } } }
        .to change(Diary, :count).by(1)

      diary = Diary.last
      expect(GeminiCorrectionService).to have_received(:new).with(diary)
      expect(service).to have_received(:call)
      expect(response).to redirect_to(diary_path(diary))
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
