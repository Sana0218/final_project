# frozen_string_literal: true

class GeminiCorrectionService
  URI_BASE = 'https://generativelanguage.googleapis.com/v1beta/openai/'
  MODEL = 'gemini-3.6-flash'
  SYSTEM_PROMPT = <<~PROMPT.chomp
    You are a helpful English tutor. The user will provide a diary entry
    containing a mix of Japanese and English.
    Task:
    1. Translate Japanese parts into natural English and correct grammatical
    errors in the English parts.
    2. Provide feedback in Japanese.
    Return JSON with keys corrected_text (English) and feedback (Japanese).
  PROMPT

  def initialize(content)
    @content = content
  end

  def call
    text = response.dig('choices', 0, 'message', 'content')
    parsed = JSON.parse(text)
    {
      corrected_text: parsed['corrected_text'],
      feedback: parsed['feedback']
    }
  end

  private

  def response
    client.chat(parameters: chat_params)
  end

  def client
    OpenAI::Client.new(
      access_token: ENV.fetch('GEMINI_API_KEY', nil),
      uri_base: URI_BASE
    )
  end

  def chat_params
    {
      response_format: { type: 'json_object' },
      model: MODEL,
      messages: [
        { role: 'system', content: SYSTEM_PROMPT },
        { role: 'user', content: @content }
      ]
    }
  end
end
