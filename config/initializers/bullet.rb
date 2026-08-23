# frozen_string_literal: true

if Rails.env.local?
  Rails.application.configure do
    config.after_initialize do
      Bullet.enable = true
      Bullet.bullet_logger = true
      Bullet.alert = true
      Bullet.console = true
      Bullet.rails_logger = true
      Bullet.raise = true if Rails.env.test?
    end
  end
end
