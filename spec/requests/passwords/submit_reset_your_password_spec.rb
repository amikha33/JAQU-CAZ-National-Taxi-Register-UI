# frozen_string_literal: true

require 'rails_helper'

describe 'PasswordsController - POST #submit_reset_your_password', type: :request do
  subject { post submit_reset_your_password_passwords_path, params: }

  let(:params) { { user: { username: } } }
  let(:username) { 'example@example.com' }

  context 'with valid email address' do
    before do
      allow(Cognito::ForgotPassword::InitiateReset).to receive(:call).with(username:).and_return(true)
      subject
    end

    it 'redirects to reset_your_password page' do
      expect(response).to redirect_to(email_send_passwords_path)
    end

    it 'returns 302 status code' do
      expect(response).to have_http_status(:redirect)
    end
  end

  context 'when service raises `ServiceError` exception' do
    let(:fallback_path) { reset_passwords_path }

    before do
      allow(Cognito::ForgotPassword::InitiateReset)
        .to receive(:call)
        .with(username:)
        .and_raise(Cognito::CallException.new('Something went wrong', fallback_path))
      subject
    end

    it 'redirects to fallback path' do
      expect(response).to redirect_to(fallback_path)
    end

    it 'returns proper error message' do
      expect(flash[:alert]).to eq('Something went wrong')
    end
  end

  context 'with invalid email address' do
    let(:username) { 'invalid email' }

    before { subject }

    it 'redirects to reset_your_password page' do
      expect(response).to redirect_to(reset_passwords_path)
    end

    it 'shows proper error message' do
      expect(flash[:alert]).to eq('Enter your email address in a valid format')
    end
  end

  context 'with empty username' do
    let(:username) { '' }

    before { subject }

    it 'redirects to reset_your_password page' do
      expect(response).to redirect_to(reset_passwords_path)
    end

    it 'shows proper error message' do
      expect(flash[:alert]).to eq('Enter your email address')
    end
  end
end
