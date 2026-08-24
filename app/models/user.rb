# frozen_string_literal: true

class User < ApplicationRecord
  authenticates_with_sorcery!

  has_many :diaries, dependent: :destroy
  has_many :user_phrases, dependent: :destroy
  has_many :phrases, through: :user_phrases

  LINK_TOKEN_TTL = 24.hours
  TIME_ZONE_OPTIONS = ['Asia/Tokyo'].freeze

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }
  validates :reminder_hour, inclusion: { in: 0..23 }
  validates :reminder_minute, inclusion: { in: 0..59 }
  validates :time_zone, inclusion: { in: TIME_ZONE_OPTIONS }

  scope :reminder_configured, -> { where(reminder_enabled: true).where.not(line_user_id: nil) }

  def generate_line_link_token!
    update!(
      line_link_token: SecureRandom.alphanumeric(8).upcase,
      line_link_token_expires_at: LINK_TOKEN_TTL.from_now
    )
  end

  def link_token_valid?
    line_link_token.present? && line_link_token_expires_at.present? && line_link_token_expires_at > Time.current
  end

  def line_linked?
    line_user_id.present?
  end

  def reminder_due?(reference_time = Time.current)
    return false unless reminder_enabled? && line_user_id.present?

    local_time = reference_time.in_time_zone(time_zone)
    return false unless local_time.hour == reminder_hour && local_time.min == reminder_minute
    return false if reminder_sent_on?(local_time.to_date)

    true
  end

  def reminder_sent_on?(date)
    last_reminder_sent_at&.in_time_zone(time_zone)&.to_date == date
  end

  def reminder_time_label
    format('%<hour>02d:%<minute>02d', hour: reminder_hour, minute: reminder_minute)
  end
end
