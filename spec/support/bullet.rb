# frozen_string_literal: true

RSpec.configure do |config|
  config.before do
    Bullet.start_request if defined?(Bullet)
  end

  config.after do
    if defined?(Bullet)
      Bullet.perform_out_of_channel_notifications if Bullet.notification?
      Bullet.end_request
    end
  end
end
