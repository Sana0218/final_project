# frozen_string_literal: true

RSpec.shared_context 'with signed in user' do
  let(:user) do
    User.create!(name: 'Test', email: 'test@example.com', password: 'password', password_confirmation: 'password')
  end

  before { post login_path, params: { email: user.email, password: 'password' } }
end
