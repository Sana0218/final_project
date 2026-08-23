# frozen_string_literal: true

class PhraseSaveService
  MAX_PHRASES = 3

  def initialize(user:, phrase_contents:)
    @user = user
    @phrase_contents = normalize(phrase_contents)
  end

  def call
    @phrase_contents.filter_map do |content|
      save_phrase(content)
    end
  end

  private

  def normalize(contents)
    Array(contents).map { |content| content.to_s.strip }.compact_blank.uniq.first(MAX_PHRASES)
  end

  def save_phrase(content)
    phrase = Phrase.find_or_create_by!(content: content)
    user_phrase = @user.user_phrases.find_or_initialize_by(phrase: phrase)
    ReviewScheduleInitializer.new(user_phrase).call
    phrase
  end
end
