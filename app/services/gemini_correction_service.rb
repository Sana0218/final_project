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
    Return JSON with keys corrected_text (English), feedback (Japanese),
    and suggested_phrases (array of exactly 3 useful English phrases to learn).
  PROMPT
  REVIEW_SYSTEM_PROMPT = <<~PROMPT.chomp
    You are a helpful English tutor. The learner is practicing target English
    phrases by writing an original sentence or short paragraph.
    Task:
    1. Correct the writing into natural English. Keep target phrases when they
    are used correctly.
    2. Give feedback in Japanese about grammar and whether the phrases were
    used naturally. Mention any unused target phrases briefly.
    Return JSON with keys corrected_text (English), feedback (Japanese),
    and suggested_phrases (array of exactly 3 useful English phrases to learn).
  PROMPT

  def initialize(diary, practice_phrases: [])
    @diary = diary
    @practice_phrases = Array(practice_phrases).compact_blank
  end

  def call
    parsed = parse_correction
    @diary.update(
      corrected_text: parsed['corrected_text'],
      feedback: parsed['feedback'],
      suggested_phrases: parsed['suggested_phrases']
    )
  rescue StandardError => e
    Rails.logger.error("[GeminiCorrectionService] #{e.class}: #{e.message}")
    false
  end

  private

  def parse_correction
    text = response.dig('choices', 0, 'message', 'content')
    JSON.parse(text)
  end

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
        { role: 'system', content: system_prompt },
        { role: 'user', content: user_content }
      ]
    }
  end

  def system_prompt
    @practice_phrases.any? ? REVIEW_SYSTEM_PROMPT : SYSTEM_PROMPT
  end

  def user_content
    return @diary.content if @practice_phrases.empty?

    phrase_lines = @practice_phrases.map { |phrase| "- #{phrase}" }.join("\n")
    <<~TEXT.chomp
      Target phrases to practice:
      #{phrase_lines}

      Learner's writing:
      #{@diary.content}
    TEXT
  end
end
