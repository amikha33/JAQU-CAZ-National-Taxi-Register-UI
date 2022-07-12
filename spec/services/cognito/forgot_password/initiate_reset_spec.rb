# frozen_string_literal: true

require 'rails_helper'

describe Cognito::ForgotPassword::InitiateReset do
  subject(:service_call) { described_class.call(username:) }

  let(:username) { 'example@example.com' }
  let(:rate_limit_verification_response) { DateTime.current.to_i }
  let(:form) { Struct.new(:valid?).new(true) }

  before do
    allow(ResetPasswordForm).to receive(:new).with(username).and_return(form)
    allow(Cognito::ForgotPassword::RateLimitVerification).to receive(:call).and_return(rate_limit_verification_response)
    allow(ResetPasswordMailer).to receive(:call).and_return(true)
    allow(Cognito::ForgotPassword::CreateResetPasswordJwt).to receive(:call).and_return('String')
  end

  context 'when form is valid and cognito returns 200 OK status' do
    before { service_call }

    it 'calls CreateResetPasswordJwt service' do
      expect(Cognito::ForgotPassword::CreateResetPasswordJwt).to have_received(:call)
    end

    it 'calls RateLimitVerification service' do
      expect(Cognito::ForgotPassword::RateLimitVerification).to have_received(:call)
    end

    it 'calls ResetPasswordMailer service' do
      expect(ResetPasswordMailer).to have_received(:call)
    end
  end

  context 'when form in invalid' do
    let(:username) { 'email' }
    let(:form) { Struct.new(:valid?, :message).new(false, 'Invalid email') }

    it 'raises the `Cognito::CallException` exception' do
      expect { service_call }.to raise_exception(Cognito::CallException)
    end
  end

  context 'when `CheckLimit.call` fails with proper params' do
    context 'when service raises `Cognito::CallException` exception' do
      before do
        allow(Cognito::ForgotPassword::RateLimitVerification).to receive(:call).and_raise(
          Cognito::CallException.new('', 'error_path')
        )
      end

      it 'raises the `Cognito::CallException` exception' do
        expect { service_call }.to raise_exception(Cognito::CallException)
      end
    end
  end
end
