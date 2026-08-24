# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LineAccountLinkService do
  let(:user) do
    User.create!(
      name: 'Test',
      email: 'line-link@example.com',
      password: 'password',
      password_confirmation: 'password',
      line_link_token: 'ABCD1234',
      line_link_token_expires_at: 1.hour.from_now
    )
  end

  it 'links a valid token to the LINE user id' do
    user
    result = described_class.new(line_user_id: 'U123', token: 'abcd1234').call

    expect(result[:success]).to be(true)
    expect(user.reload.line_user_id).to eq('U123')
    expect(user.line_link_token).to be_nil
  end

  it 'returns failure for an invalid token' do
    result = described_class.new(line_user_id: 'U123', token: 'INVALID1').call

    expect(result[:success]).to be(false)
    expect(result[:message]).to include('無効')
  end

  it 'returns failure when LINE account is linked to another user' do
    User.create!(
      name: 'Other',
      email: 'other@example.com',
      password: 'password',
      password_confirmation: 'password',
      line_user_id: 'U999'
    )

    result = described_class.new(line_user_id: 'U999', token: user.line_link_token).call

    expect(result[:success]).to be(false)
    expect(result[:message]).to include('連携済み')
  end
end
