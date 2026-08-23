# frozen_string_literal: true

class PhrasesController < ApplicationController
  def index
    @user_phrases = current_user.user_phrases.with_phrase.recent
  end
end
