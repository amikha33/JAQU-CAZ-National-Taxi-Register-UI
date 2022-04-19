# frozen_string_literal: true

require 'rails_helper'

describe Cognito::AuthUser do
  subject(:service_call) { described_class.call(username:, password:, login_ip: remote_ip) }

  let(:username) { 'user@example.com' }
  let(:password) { 'password' }
  let(:remote_ip) { '127.0.0.1' }
  let(:auth_params) do
    {
      client_id: anything,
      auth_flow: 'USER_PASSWORD_AUTH',
      auth_parameters: { 'USERNAME' => username, 'PASSWORD' => password }
    }
  end

  context 'with successful call' do
    before do
      allow(Cognito::Client.instance).to receive(:initiate_auth).with(auth_params).and_return(auth_response)
      allow(Cognito::Client.instance).to receive(:admin_list_groups_for_user).and_return(
        Struct.new(:groups).new([Struct.new(:group_name).new('ntr.search.dev')])
      )
    end

    context 'when user changed the password' do
      let(:token) { SecureRandom.uuid }
      let(:auth_response) { Struct.new(:authentication_result).new(Struct.new(:access_token).new(token)) }

      before do
        allow(Cognito::GetUser).to receive(:call).and_return(User.new)
        user_groups_response = Struct.new(:groups).new([Struct.new(:group_name).new('ntr.search.dev')])
        allow(Cognito::GetUser).to receive(:call).and_return(user_groups_response)
        allow(Cognito::GetUserGroups).to receive(:call).and_return(user_groups_response)
      end

      it 'calls `Cognito::GetUser`' do
        service_call
        expect(Cognito::GetUser).to have_received(:call)
          .with(access_token: token, username:, user: an_instance_of(User))
      end

      it 'calls `Cognito::GetUserGroups`' do
        service_call
        expect(Cognito::GetUserGroups).to have_received(:call).with(username:)
      end
    end

    context 'when user did not change the password' do
      let(:email) { 'test@example.com' }
      let(:session_key) { SecureRandom.uuid }
      let(:auth_response) do
        Struct.new(:authentication_result, :challenge_parameters, :session).new(
          nil, { 'USER_ID_FOR_SRP' => username, 'userAttributes' => { 'email' => email }.to_json }, session_key
        )
      end

      it 'returns an instance of the user class' do
        expect(service_call).to be_a(User)
      end

      it 'sets user email' do
        expect(service_call.email).to eq(email)
      end

      it 'sets username' do
        expect(service_call.username).to eq(username)
      end

      it 'sets aws_status to FORCE_NEW_PASSWORD' do
        expect(service_call.aws_status).to eq('FORCE_NEW_PASSWORD')
      end

      it 'sets aws_session' do
        expect(service_call.aws_session).to eq(session_key)
      end

      it 'sets hashed password' do
        expect(service_call.hashed_password).to eq(Digest::MD5.hexdigest(password))
      end

      it 'sets login_ip' do
        expect(service_call.login_ip).to eq(remote_ip)
      end

      it 'sets groups' do
        expect(service_call.groups).to eq(%w[ntr.search.dev])
      end
    end
  end

  context 'when `initiate_auth` call raises exception' do
    before do
      allow(Cognito::Client.instance).to receive(:initiate_auth)
        .and_raise(Aws::CognitoIdentityProvider::Errors::NotAuthorizedException.new('', 'error'))
    end

    it 'returns false' do
      expect(service_call).to be_falsey
    end
  end

  context 'when `admin_list_groups_for_user` call raises exception' do
    before do
      allow(Cognito::Client.instance).to receive(:initiate_auth)
        .with(auth_params).and_return(
          Struct.new(:authentication_result).new(Struct.new(:access_token).new(SecureRandom.uuid))
        )
      allow(Cognito::Client.instance).to receive(:admin_list_groups_for_user)
        .and_raise(Aws::CognitoIdentityProvider::Errors::ServiceError.new('', 'error'))
      allow(Cognito::GetUser).to receive(:call).and_return(User.new)
    end

    it 'returns false' do
      expect(service_call).to be_falsey
    end
  end
end
