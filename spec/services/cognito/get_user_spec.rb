# frozen_string_literal: true

require 'rails_helper'

describe Cognito::GetUser do
  subject(:service_call) { described_class.call(access_token: token, username:) }

  let(:token) { SecureRandom.uuid }
  let(:cognito_response) do
    mock = Struct.new(:name, :value)
    Struct.new(:username, :user_attributes).new(username, [
                                                  mock.new('email', email),
                                                  mock.new('preferred_username', preferred_username),
                                                  mock.new('sub', sub)
                                                ])
  end
  let(:email) { 'test@example.com' }
  let(:username) { 'wojtek' }
  let(:preferred_username) { SecureRandom.uuid }
  let(:sub) { SecureRandom.uuid }

  before do
    allow(Cognito::Client.instance).to receive(:get_user)
      .with(access_token: token)
      .and_return(cognito_response)
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

  it 'sets aws_status to OK' do
    expect(service_call.aws_status).to eq('OK')
  end

  it 'sets aws_session to nil' do
    expect(service_call.aws_session).to be_nil
  end

  describe '.preferred_username' do
    context 'when preferred_username not nil' do
      it 'returns a proper value' do
        expect(service_call.preferred_username).to eq(preferred_username)
      end
    end

    context 'when preferred_username is nil' do
      let(:preferred_username) { nil }

      it 'returns a proper value' do
        expect(service_call.preferred_username).to eq(sub)
      end
    end
  end

  context 'when the initial user is given' do
    subject(:service_call) do
      described_class.call(access_token: token, username:, user:)
    end

    let(:user) { User.new(login_ip: remote_ip) }
    let(:remote_ip) { '127.0.0.1' }

    it 'does not override login_ip' do
      expect(service_call.login_ip).to eq(remote_ip)
    end
  end
end
