# frozen_string_literal: true

require 'rails_helper'

describe Cognito::Lockout::UpdateUser do
  subject { described_class.call(username:, failed_logins:, lockout_time:) }

  let(:username) { 'user@example.com' }
  let(:failed_logins) { 3 }
  let(:lockout_time) { Time.zone.now.iso8601 }
  let(:user_attributes) do
    [
      {
        name: 'custom:failed-logins',
        value: failed_logins.to_s
      },
      {
        name: 'custom:lockout-time',
        value: lockout_time.to_s
      }
    ]
  end

  before { allow(Cognito::Client.instance).to receive(:admin_update_user_attributes).and_return(true) }

  context 'with successful call' do
    it 'calls Cognito with proper params and returns true' do
      subject
      expect(Cognito::Client.instance).to have_received(:admin_update_user_attributes).with(
        user_pool_id: anything, username:, user_attributes:
      )
    end
  end

  context 'when `Cognito::Client.instance.admin_update_user_attributes`
 call fails with proper params' do
    context 'and service raises `ServiceError`' do
      before do
        allow(Cognito::Client.instance).to receive(:admin_update_user_attributes).and_raise(
          Aws::CognitoIdentityProvider::Errors::ServiceError.new('', 'error')
        )
      end

      it 'raises the `CallException`' do
        expect { subject }.to raise_exception(Cognito::CallException)
      end
    end

    context 'and service raises `UserNotFoundException`' do
      before do
        allow(Cognito::Client.instance).to receive(:admin_update_user_attributes).and_raise(
          Aws::CognitoIdentityProvider::Errors::UserNotFoundException.new('', '')
        )
      end

      it 'raises the `CallException`' do
        expect { subject }.to raise_exception(Cognito::CallException)
      end
    end
  end
end
