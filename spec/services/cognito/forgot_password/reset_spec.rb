# frozen_string_literal: true

require 'rails_helper'

describe Cognito::ForgotPassword::Reset do
  subject(:service_call) { described_class.call(username: username) }

  let(:username) { 'wojtek@email.com' }
  let(:cognito_response) { true }
  let(:form) { Struct.new(:valid?).new(true) }

  before do
    allow(ResetPasswordForm).to receive(:new).with(username).and_return(form)
    allow(Cognito::ForgotPassword::RateLimitVerification).to receive(:call).with(username: username).and_return(true)
    allow(Cognito::Client.instance).to receive(:forgot_password).with(
      client_id: anything,
      username: username
    ).and_return(cognito_response)
  end

  context 'when form is valid and cognito returns 200 OK status' do
    it 'returns true' do
      expect(service_call).to be_truthy
    end

    it 'calls ResetPasswordForm' do
      service_call
      expect(ResetPasswordForm).to have_received(:new).with(username)
    end

    it 'calls Cognito' do
      service_call
      expect(Cognito::Client.instance).to have_received(:forgot_password)
    end
  end

  context 'when form is invalid' do
    let(:cognito_response) { true }
    let(:form) { Struct.new(:valid?, :message).new(false, error) }
    let(:error) { 'Something went wrong' }

    it 'raises exception with proper params' do
      expect { service_call }.to raise_exception(Cognito::CallException, error) { |ex|
        ex.path == '/passwords/reset'
      }
    end
  end

  context 'when `Cognito.forgot_password` call fails with proper params' do
    context 'when service raises `ServiceError` exception' do
      before do
        allow(Cognito::Client.instance).to receive(:forgot_password).with(
          client_id: anything,
          username: username
        ).and_raise(
          Aws::CognitoIdentityProvider::Errors::ServiceError.new('', 'error')
        )
      end

      it 'returns true' do
        expect(service_call).to be_truthy
      end
    end

    context 'when service raises `UserNotFoundException` exception' do
      before do
        allow(Cognito::Client.instance).to receive(:forgot_password).with(
          client_id: anything,
          username: username
        ).and_raise(
          Aws::CognitoIdentityProvider::Errors::UserNotFoundException.new('', 'error')
        )
      end

      it 'returns true' do
        expect(service_call).to be_truthy
      end
    end
  end

  context 'when `CheckLimit.call` fails with proper params' do
    context 'when service raises `Cognito::CallException` exception' do
      before do
        allow(Cognito::ForgotPassword::RateLimitVerification).to receive(:call).with(
          username: username
        ).and_raise(
          Cognito::CallException.new('', 'error_path')
        )
      end

      it 'raises the `Cognito::CallException` exception' do
        expect { service_call }.to raise_exception(Cognito::CallException)
      end
    end

    context 'when service raises `UserNotFoundException` exception' do
      before do
        allow(Cognito::Client.instance).to receive(:forgot_password).with(
          client_id: anything,
          username: username
        ).and_raise(
          Aws::CognitoIdentityProvider::Errors::UserNotFoundException.new('', 'error')
        )
      end

      it 'returns true' do
        expect(service_call).to be_truthy
      end
    end
  end
end
