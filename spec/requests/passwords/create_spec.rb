# frozen_string_literal: true

require 'rails_helper'

describe 'PasswordsController - POST #create', type: :request do
  subject(:http_request) { post passwords_path, params: params }

  let(:params) { {} }

  before { sign_in user }

  context 'when user aws_status is OK' do
    let(:user) { new_user(aws_status: 'OK') }

    it 'returns a redirect to root_path' do
      http_request
      expect(response).to redirect_to(root_path)
    end
  end

  context 'when user aws_session is missing' do
    let(:user) { new_user(aws_status: 'FORCE_NEW_PASSWORD') }

    it 'returns a redirect to new_user_session_path' do
      http_request
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context 'with aws status and session' do
    let(:user) do
      new_user(aws_status: 'FORCE_NEW_PASSWORD', aws_session: SecureRandom.uuid)
    end

    context 'when params are empty or not equal' do
      before { http_request }

      describe 'password' do
        let(:params) { { user: { password: nil, password_confirmation: 'test' } } }

        it 'returns a redirect to new_password_path' do
          expect(response).to redirect_to(new_password_path)
        end
      end

      describe 'password confirmation' do
        let(:params) { { user: { password: 'test', password_confirmation: nil } } }

        it 'returns a redirect to new_password_path' do
          expect(response).to redirect_to(new_password_path)
        end
      end

      describe 'not equal' do
        let(:params) { { user: { password: 'test', password_confirmation: 'test1' } } }

        it 'returns a redirect to new_password_path' do
          expect(response).to redirect_to(new_password_path)
        end
      end
    end

    context 'with valid params' do
      let(:params) { { user: { password: 'test', password_confirmation: 'test' } } }

      context 'when call to AWS is successful' do
        before do
          allow(Cognito::RespondToAuthChallenge).to receive(:call).and_return(true)
          http_request
        end

        it 'returns a redirect to success_passwords_path' do
          expect(response).to redirect_to(success_passwords_path)
        end
      end

      context 'when call to AWS raises invalid password' do
        before do
          allow(Cognito::RespondToAuthChallenge).to receive(:call).and_raise(
            Aws::CognitoIdentityProvider::Errors::InvalidPasswordException.new('', '')
          )
          http_request
        end

        it 'returns a redirect to new_password_path' do
          expect(response).to redirect_to(new_password_path)
        end

        it 'does not log out user' do
          expect(controller.current_user).to eq(user)
        end
      end

      context 'when call to AWS raises other error' do
        before do
          allow(Cognito::RespondToAuthChallenge).to receive(:call).and_raise(
            Aws::CognitoIdentityProvider::Errors::NotAuthorizedException.new('', '')
          )
          http_request
        end

        it 'returns a redirect to new_password_path' do
          expect(response).to redirect_to(new_user_session_path)
        end

        it 'logs out user' do
          expect(controller.current_user).to eq(nil)
        end
      end
    end
  end
end
