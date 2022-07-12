# frozen_string_literal: true

require 'rails_helper'

describe Cognito::ForgotPassword::ChangePassword do
  subject(:service_call) do
    described_class.call(username:, password:, password_confirmation: password, token:)
  end

  let(:username) { 'example@example.com' }
  let(:password) { 'pAssword!' }
  let(:token) { 'random string' }
  let(:cognito_response) { true }
  let(:form) { Struct.new(:valid?).new(true) }

  before do
    allow(Cognito::Client.instance).to receive(:admin_set_user_password).and_return(cognito_response)
    allow(ConfirmResetPasswordForm).to receive(:new).with(
      password:, confirmation: password
    ).and_return(form)
  end

  context 'when form is valid and cognito returns 200 OK status' do
    before do
      allow(Cognito::ForgotPassword::ValidateResetPasswordJwt).to receive(:call).with(token:).and_return(username)
      allow(Cognito::Lockout::UpdateUser).to receive(:call).with(username:, failed_logins: 0).and_return(true)
      allow(Cognito::ForgotPassword::UpdateUser).to receive(:call).with(reset_counter: 1, username:).and_return(true)
    end

    it 'returns true' do
      expect(service_call).to be_truthy
    end

    it 'calls ResetPasswordForm' do
      service_call
      expect(ConfirmResetPasswordForm).to have_received(:new)
    end

    it 'calls Cognito' do
      service_call
      expect(Cognito::Client.instance).to have_received(:admin_set_user_password)
    end
  end

  context 'when form is invalid' do
    let(:cognito_response) { true }
    let(:form) { Struct.new(:valid?, :message).new(false, error) }
    let(:error) { 'Something went wrong' }

    before do
      allow(Cognito::ForgotPassword::ValidateResetPasswordJwt).to receive(:call).with(token:).and_return(username)
    end

    it 'raises exception with proper params' do
      expect { service_call }.to raise_exception(Cognito::CallException, error.to_json)
    end
  end

  context 'when Cognito call fails' do
    let(:error) { "User with username '#{username}' was not found" }

    before do
      allow(Cognito::ForgotPassword::ValidateResetPasswordJwt).to receive(:call).with(token:).and_return(username)
      allow(Cognito::Client.instance).to receive(:admin_set_user_password).and_raise(exception)
    end

    describe 'Aws::CognitoIdentityProvider::Errors::InvalidPasswordException' do
      let(:exception) { Aws::CognitoIdentityProvider::Errors::InvalidPasswordException.new('', '') }

      it 'raises exception with proper params' do
        expect { service_call }.to raise_exception(Cognito::CallException, I18n.t('password.errors.complexity'))
      end
    end

    describe 'Aws::CognitoIdentityProvider::Errors::UserNotFoundException' do
      let(:exception) { Aws::CognitoIdentityProvider::Errors::UserNotFoundException.new('', '') }

      it 'raises exception with proper params' do
        expect { service_call }.to raise_exception(Cognito::CallException, 'Something went wrong')
      end
    end

    describe 'other error' do
      let(:exception) { Aws::CognitoIdentityProvider::Errors::InternalErrorException.new('', '') }

      it 'raises exception with proper params' do
        expect { service_call }.to raise_exception(Cognito::CallException, 'Something went wrong')
      end
    end
  end
end
