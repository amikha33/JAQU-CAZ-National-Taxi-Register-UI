# frozen_string_literal: true

require 'rails_helper'

describe 'PasswordsController - POST #change', type: :request do
  subject { post change_passwords_path, params: }

  let(:params) do
    {
      user: {
        username:,
        password:,
        password_confirmation:,
        token: password_reset_token
      }
    }
  end
  let(:username) { 'example@example.com' }
  let(:password) { 'pAssword!' }
  let(:password_confirmation) { 'pAssword!' }
  let(:password_reset_token) { 'someToken' }

  context 'with password_reset_token set' do
    before do
      inject_session(password_reset_token:)
      allow(Cognito::ForgotPassword::ChangePassword).to receive(:call).with(
        username:, password:, password_confirmation:, token: password_reset_token
      ).and_return(true)
    end

    it 'returns redirect to success page' do
      subject
      expect(response).to redirect_to(success_passwords_path)
    end

    it 'clears password_reset_token' do
      subject
      expect(session[:password_reset_token]).to be_nil
    end
  end

  context 'when change password service throws exception' do
    before do
      inject_session(password_reset_token:)
      allow(Cognito::ForgotPassword::ChangePassword).to receive(:call).with(
        username:, password:, password_confirmation:, token: password_reset_token
      ).and_raise(Cognito::CallException.new('Some message'))
    end

    it 'returns redirect to success page' do
      subject
      expect(response).to redirect_to(confirm_reset_passwords_path)
    end

    it 'shows expected flash message' do
      subject
      expect(flash[:alert]).to eq('Some message')
    end

    it 'does not clear password_reset_token' do
      subject
      expect(session[:password_reset_token]).to eq(password_reset_token)
    end
  end
end
