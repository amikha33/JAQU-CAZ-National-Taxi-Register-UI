# frozen_string_literal: true

require 'rails_helper'

describe Cognito::ForgotPassword::Confirm do
  subject(:service_call) do
    described_class.call(username:, password:, code:, password_confirmation: password)
  end

  let(:username) { 'wojtek@example.com' }
  let(:password) { 'password' }
  let(:code) { '123456' }
  let(:cognito_response) { true }
  let(:form) { Struct.new(:valid?).new(true) }

  before do
    allow(Cognito::Client.instance).to receive(:confirm_forgot_password).with(
      client_id: anything, username:, password:, confirmation_code: code
    ).and_return(cognito_response)

    allow(ConfirmResetPasswordForm).to receive(:new).with(
      password:, confirmation: password, code:
    ).and_return(form)
  end

  context 'when form is valid and cognito returns 200 OK status' do
    it 'returns true' do
      expect(service_call).to be_truthy
    end

    it 'calls ResetPasswordForm' do
      service_call
      expect(ConfirmResetPasswordForm).to have_received(:new)
    end

    it 'calls Cognito' do
      service_call
      expect(Cognito::Client.instance).to have_received(:confirm_forgot_password)
    end
  end

  context 'when form is invalid' do
    let(:cognito_response) { true }
    let(:form) { Struct.new(:valid?, :message).new(false, error) }
    let(:error) { 'Something went wrong' }

    it 'raises exception with proper params' do
      expect { service_call }.to raise_exception(Cognito::CallException, error)
    end
  end

  context 'when Cognito call fails' do
    let(:error) { "User with username '#{username}' was not found" }

    before do
      allow(Cognito::Client.instance).to receive(:confirm_forgot_password).with(
        client_id: anything, username:, password:, confirmation_code: code
      ).and_raise(exception)
    end

    describe 'Aws::CognitoIdentityProvider::Errors::CodeMismatchException' do
      let(:exception) { Aws::CognitoIdentityProvider::Errors::CodeMismatchException.new('', '') }

      it 'raises exception with proper params' do
        expect { service_call }.to raise_exception(
          Cognito::CallException,
          I18n.t('password.errors.code_mismatch')
        )
      end
    end

    describe 'Aws::CognitoIdentityProvider::Errors::InvalidPasswordException' do
      let(:exception) { Aws::CognitoIdentityProvider::Errors::InvalidPasswordException.new('', '') }

      it 'raises exception with proper params' do
        expect { service_call }.to raise_exception(Cognito::CallException, I18n.t('password.errors.complexity'))
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
