# frozen_string_literal: true

require 'rails_helper'

describe Cognito::ForgotPassword::RateLimitVerification do
  subject(:service_call) { described_class.call(username:, current_date_time:) }

  let(:username) { 'user@example.com' }
  let(:admin_get_user_response) do
    mock = Struct.new(:name, :value)
    Struct.new(:user_attributes).new([mock.new('custom:pw-reset-counter', reset_counter),
                                      mock.new('custom:pw-reset-requested', reset_requested)])
  end
  let(:reset_counter) { '0' }
  let(:reset_requested) { nil }
  let(:current_date_time) { DateTime.current }

  before do
    allow(Cognito::Client.instance).to receive(:admin_get_user).and_return(admin_get_user_response)
    allow(Cognito::ForgotPassword::UpdateUser).to receive(:call).with(reset_counter: 1,
                                                                      username:,
                                                                      current_date_time:).and_return(true)
  end

  context 'when password reset counter no more than five' do
    it 'calls `Cognito::ForgotPassword::UpdateUser` with increased reset_counter' do
      service_call
      expect(Cognito::ForgotPassword::UpdateUser).to have_received(:call).with(
        reset_counter: 1, username:, current_date_time:
      )
    end
  end

  context 'when password reset counter more than five' do
    let(:reset_counter) { '6' }

    context 'and request was made more than 1 hour ago' do
      let(:reset_requested) { (DateTime.current - 2.hours).to_i.to_s }

      it 'calls `Cognito::ForgotPassword::UpdateUser` and reset reset_counter to 1' do
        service_call
        expect(Cognito::ForgotPassword::UpdateUser).to have_received(:call).with(
          reset_counter: 1, username:, current_date_time:
        )
      end
    end

    context 'and request was made less than 1 hour ago' do
      let(:reset_requested) { (DateTime.current - 30.minutes).to_i.to_s }

      it 'dont reset `reset_counter`' do
        expect(Cognito::ForgotPassword::UpdateUser).not_to have_received(:call)
      end

      it 'raises `Cognito::CallException` exception with proper params' do
        expect { service_call }.to raise_exception(Cognito::CallException, 'Something went wrong') { |exception|
          exception.message.empty?
          exception.path == '/passwords/invalid_or_expired'
        }
      end
    end
  end

  context 'when `Cognito::Client.instance.admin_get_user` call fails with proper params' do
    context 'and service raises `ServiceError`' do
      before do
        allow(Cognito::Client.instance).to receive(:admin_get_user).and_raise(
          Aws::CognitoIdentityProvider::Errors::ServiceError.new('', 'error')
        )
      end

      it 'raises the `CallException`' do
        expect { service_call }.to raise_exception(Cognito::CallException)
      end
    end

    context 'and service raises `UserNotFoundException`' do
      before do
        allow(Cognito::Client.instance).to receive(:admin_get_user).and_raise(
          Aws::CognitoIdentityProvider::Errors::UserNotFoundException.new('', '')
        )
      end

      it 'raises the `CallException`' do
        expect { service_call }.to raise_exception(Cognito::CallException)
      end
    end
  end
end
