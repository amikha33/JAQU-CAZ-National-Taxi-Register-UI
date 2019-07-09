# frozen_string_literal: true

require 'rails_helper'

describe 'User singing in', type: :request do
  let(:email) { 'user@example.com' }
  let(:password) { '12345678' }
  let(:params) do
    {
      user: {
        email: email,
        password: password
      }
    }
  end

  describe 'requesting sign in page' do
    subject(:http_request) { post user_session_path }

    it 'redirects to login page' do
      http_request
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'signing in' do
    subject(:http_request) { post user_session_path(params) }

    context 'when incorrect credentials given' do
      before do
        expect_any_instance_of(Aws::CognitoIdentityProvider::Client).to receive(:initiate_auth)
          .and_return(false)
      end

      it 'shows `The username or password you entered is incorrect` message' do
        http_request
        expect(response.body).to include('The username or password you entered is incorrect')
      end
    end

    context 'when correct credentials given' do
      before do
        expect_any_instance_of(Aws::CognitoIdentityProvider::Client).to receive(:initiate_auth)
          .and_return(true)
      end

      it 'logs user in' do
        http_request
        expect(response).to redirect_to(root_path)
        get root_path
      end
    end
  end
end
