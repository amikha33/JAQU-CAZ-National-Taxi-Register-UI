# frozen_string_literal: true

require 'rails_helper'

describe Cognito::ForgotPassword::ConfirmResetValidator do
  subject(:service_call) { described_class.call(params:, session:) }

  let(:params) { { token: } }
  let(:session) { {} }
  let(:token) { 'tokenString' }
  let(:username) { 'example@example.com' }

  context 'when token in query' do
    before { allow(Cognito::ForgotPassword::ValidateResetPasswordJwt).to receive(:call).and_return(username) }

    it 'returns expected values' do
      expect(service_call).to eq([username, token])
    end

    it 'assigns token into session' do
      service_call
      expect(session[:password_reset_token]).to eq(token)
    end
  end

  context 'when token in session and not in params' do
    let(:params) { {} }
    let(:session) { { password_reset_token: token } }

    before { allow(Cognito::ForgotPassword::ValidateResetPasswordJwt).to receive(:call).and_return(username) }

    it 'returns expected values' do
      expect(service_call).to eq([username, token])
    end
  end

  context 'when token not in session and not in params' do
    let(:params) { {} }

    it 'throws exception' do
      expect { service_call }.to raise_exception(Cognito::CallException, '') { |exception|
        exception.message.empty?
        exception.path == '/passwords/invalid_or_expired'
      }
    end
  end
end
