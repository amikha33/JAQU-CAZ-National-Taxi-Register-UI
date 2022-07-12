# frozen_string_literal: true

require 'rails_helper'

describe Cognito::ForgotPassword::ValidateResetPasswordJwt do
  subject(:service_call) { described_class.call(token:) }

  let(:token) { JsonWebToken::Encode.call(payload:) }
  let(:payload) do
    { 'email' => username, 'exp' => (DateTime.current + 1.day).to_i, 'pw-reset-requested' => '11-11-2011' }
  end
  let(:admin_get_user_response) do
    mock = Struct.new(:name, :value)
    Struct.new(:user_attributes).new([mock.new('custom:pw-reset-requested', '11-11-2011'),
                                      mock.new('custom:pw-reset-counter', 1)])
  end
  let(:username) { 'example@example.com' }

  context 'returns expected value with valid token' do
    before do
      allow(Cognito::ForgotPassword::GetUser).to receive(:call).with(username:).and_return(admin_get_user_response)
      allow(Cognito::ForgotPassword::UpdateUser).to receive(:call).with(reset_counter: 1,
                                                                        username:).and_return(true)
    end

    it 'calls GetUser service' do
      service_call
      expect(Cognito::ForgotPassword::GetUser).to have_received(:call).with(username:)
    end

    it 'returns email address' do
      expect(service_call).to eq(username)
    end
  end

  context 'when user has no pw-reset-requested field in cognito' do
    let(:admin_get_user_response) do
      mock = Struct.new(:name, :value)
      Struct.new(:user_attributes).new([mock.new('custom:pw-reset-requested', nil)])
    end

    before do
      allow(Cognito::ForgotPassword::GetUser).to receive(:call).and_return(admin_get_user_response)
    end

    it 'raises exception' do
      expect { service_call }.to raise_exception(Cognito::CallException, '') { |exception|
        exception.message.empty?
        exception.path == '/passwords/invalid_or_expired'
      }
    end
  end

  context 'when token has expired' do
    let(:payload) do
      { 'email' => username, 'exp' => (DateTime.current - 1.day).to_i, 'pw-reset-requested' => '11-11-2011' }
    end

    before do
      allow(Cognito::ForgotPassword::GetUser).to receive(:call).and_return(admin_get_user_response)
    end

    it 'raises exception' do
      expect { service_call }.to raise_exception(Cognito::CallException, '') { |exception|
        exception.message.empty?
        exception.path == '/passwords/invalid_or_expired'
      }
    end
  end

  context 'when token has been already used' do
    let(:admin_get_user_response) do
      mock = Struct.new(:name, :value)
      Struct.new(:user_attributes).new([mock.new('custom:pw-reset-requested', 0),
                                        mock.new('custom:pw-reset-counter', 1)])
    end

    before do
      allow(Cognito::ForgotPassword::GetUser).to receive(:call).and_return(admin_get_user_response)
    end

    it 'raises exception' do
      expect { service_call }.to raise_exception(Cognito::CallException, '') { |exception|
        exception.message.empty?
        exception.path == '/passwords/invalid_or_expired'
      }
    end
  end

  context 'when user has not been found' do
    before do
      allow(Cognito::ForgotPassword::GetUser).to receive(:call).and_raise(
        Cognito::CallException.new('Something went wrong', 'some/path')
      )
    end

    it 'raises exception' do
      expect { service_call }.to raise_exception(Cognito::CallException, '') { |exception|
        exception.message.empty?
        exception.path == '/passwords/invalid_or_expired'
      }
    end
  end

  context 'when no fields in cognito' do
    let(:admin_get_user_response) do
      Struct.new(:user_attributes).new([])
    end

    it 'raises exception' do
      expect { service_call }.to raise_exception(Cognito::CallException, '') { |exception|
        exception.message.empty?
        exception.path == '/passwords/invalid_or_expired'
      }
    end
  end

  context 'when token could not be decoded' do
    before do
      allow(JsonWebToken::Decode).to receive(:call).and_raise(JWT::DecodeError)
    end

    it 'raises exception' do
      expect { service_call }.to raise_exception(Cognito::CallException, '') { |exception|
        exception.message.empty?
        exception.path == '/passwords/invalid_or_expired'
      }
    end
  end
end
