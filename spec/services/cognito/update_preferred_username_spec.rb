# frozen_string_literal: true

require 'rails_helper'

describe Cognito::UpdatePreferredUsername do
  subject { described_class.call(username:, preferred_username:, sub:) }

  let(:username) { 'user@example.com' }
  let(:preferred_username) { SecureRandom.uuid }
  let(:sub) { SecureRandom.uuid }
  let(:user_attributes) { [{ name: 'preferred_username', value: sub }] }

  before { allow(Cognito::Client.instance).to receive(:admin_update_user_attributes).and_return(true) }

  context 'when preferred_username is nil' do
    let(:preferred_username) { nil }

    context 'with successful call' do
      it 'calls Cognito with proper params and returns true' do
        subject
        expect(Cognito::Client.instance).to have_received(:admin_update_user_attributes).with(
          user_pool_id: anything, username:, user_attributes:
        )
      end
    end

    context 'when `Cognito::Client.instance.admin_update_user_attributes` call fails with proper params' do
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

    context 'when preferred_username is not nil' do
      before { allow(Cognito::Client.instance).to receive(:call) }

      it 'does not call Cognito' do
        subject
        expect(Cognito::Client.instance).not_to have_received(:call)
      end
    end
  end
end
