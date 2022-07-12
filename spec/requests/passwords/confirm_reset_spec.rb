# frozen_string_literal: true

require 'rails_helper'

describe 'PasswordsController - GET #confirm_reset', type: :request do
  subject { get confirm_reset_passwords_path(token:) }

  let(:username) { 'wojtek@example.com' }
  let(:token) { 'ExampleJwtToken' }

  context 'with valid jvt token' do
    before do
      allow(Cognito::ForgotPassword::ConfirmResetValidator).to receive(:call).and_return([username, token])
    end

    it 'returns a 200 OK status' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'assigns username class variable' do
      subject
      expect(assigns(:username)).to eq(username)
    end

    it 'assigns token class variable' do
      subject
      expect(assigns(:token)).to eq(token)
    end
  end

  context 'when token validation fails' do
    let(:fallback_path) { invalid_or_expired_passwords_path }

    before do
      allow(Cognito::ForgotPassword::ConfirmResetValidator).to receive(:call).and_raise(
        Cognito::CallException.new('Something went wrong', fallback_path)
      )
    end

    it 'redirect to invalid_or_expired page' do
      subject
      expect(response).to redirect_to(invalid_or_expired_passwords_path)
    end
  end
end
