# frozen_string_literal: true

class LineAccountLinkService
  SUCCESS_MESSAGE = 'LINE連携が完了しました。設定した時刻に学習リマインドをお届けします。'
  INVALID_TOKEN_MESSAGE = '連携コードが無効または期限切れです。アプリのマイページで新しいコードを発行してください。'
  ALREADY_LINKED_MESSAGE = 'このLINEアカウントは既に別のユーザーと連携済みです。'

  def initialize(line_user_id:, token:)
    @line_user_id = line_user_id
    @token = token.to_s.strip.upcase
  end

  def call
    return failure(INVALID_TOKEN_MESSAGE) if @token.blank?

    token_user = User.find_by(line_link_token: @token)
    return failure(INVALID_TOKEN_MESSAGE) unless token_user&.link_token_valid?
    return failure(ALREADY_LINKED_MESSAGE) if linked_to_other_user?(token_user)

    link_user(token_user)
    success(SUCCESS_MESSAGE)
  end

  private

  def linked_to_other_user?(token_user)
    existing_user = User.find_by(line_user_id: @line_user_id)
    existing_user && existing_user.id != token_user.id
  end

  def link_user(token_user)
    token_user.update!(
      line_user_id: @line_user_id,
      line_link_token: nil,
      line_link_token_expires_at: nil
    )
  end

  def success(message)
    { success: true, message: message }
  end

  def failure(message)
    { success: false, message: message }
  end
end
