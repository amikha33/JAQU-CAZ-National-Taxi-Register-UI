# frozen_string_literal: true

require 'rails_helper'

describe Cognito::ForgotPassword::CreateResetPasswordJwt do
  subject(:service_call) { described_class.call(username:, current_date_time:) }

  let(:username) { 'example@example.com' }
  let(:current_date_time) { DateTime.current.to_i }
  let(:expired_time) { DateTime.current }

  it 'returns not empty response' do
    expect(service_call).not_to be_empty
  end

  context 'jwt can be successfuly decoded' do
    before { allow(DateTime.current).to receive(:new).and_return(expired_time) }

    it 'returns expected email value' do
      expect(JsonWebToken::Decode.call(token: service_call)['email']).to eq(username)
    end

    it 'returns expected pw-reset-request value' do
      expect(JsonWebToken::Decode.call(token: service_call)['pw-reset-requested']).to eq(current_date_time)
    end

    it 'returns expected exp value' do
      expect(JsonWebToken::Decode.call(token: service_call)['exp']).to eq((expired_time + 1.day).to_i)
    end
  end
end
