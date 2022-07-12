# frozen_string_literal: true

require 'rails_helper'

describe ConfirmResetPasswordForm do
  subject(:form) { described_class.new(password:, confirmation: password_confirmation) }

  let(:password) { 'passwOrd1' }
  let(:password_confirmation) { 'passwOrd1' }

  it 'is valid with a proper password' do
    expect(form).to be_valid
  end

  context 'when password is empty' do
    let(:password) { '' }

    it 'is not valid' do
      expect(form).not_to be_valid
    end

    it 'has a proper error message' do
      form.valid?
      expect(form.message[:password]).to eq(I18n.t('password.errors.password_required'))
    end
  end

  context 'when password confirmation is empty' do
    let(:password_confirmation) { '' }

    it 'is not valid' do
      expect(form).not_to be_valid
    end

    it 'has a proper error message' do
      form.valid?
      expect(form.message[:password_confirmation]).to eq(I18n.t('password.errors.password_confirmation_required'))
    end
  end

  context 'when password confirmation is different' do
    let(:password_confirmation) { 'other_password' }

    it 'is not valid' do
      expect(form).not_to be_valid
    end

    it 'has a proper password_confirmation error message' do
      form.valid?
      expect(form.message[:password_confirmation]).to eq(I18n.t('password.errors.password_equality'))
    end

    it 'has a proper password error message' do
      form.valid?
      expect(form.message[:password]).to eq(I18n.t('password.errors.password_equality'))
    end
  end

  context 'when password dont meet complexity requirements' do
    let(:password) { 'otherpassword' }
    let(:password_confirmation) { 'otherpassword' }

    it 'is not valid' do
      expect(form).not_to be_valid
    end

    it 'has a proper password error message' do
      form.valid?
      expect(form.message[:password]).to eq(I18n.t('password.errors.complexity'))
    end
  end

  context 'when password dont contain uppercase letter' do
    let(:password) { 'other_password1' }
    let(:password_confirmation) { 'other_password1' }

    it 'is not valid' do
      expect(form).not_to be_valid
    end

    it 'has a proper password error message' do
      form.valid?
      expect(form.message[:password]).to eq(I18n.t('password.errors.complexity'))
    end
  end

  context 'when password dont contain digit' do
    let(:password) { 'otherpassworD' }
    let(:password_confirmation) { 'otherpassworD' }

    it 'is not valid' do
      expect(form).not_to be_valid
    end

    it 'has a proper password error message' do
      form.valid?
      expect(form.message[:password]).to eq(I18n.t('password.errors.complexity'))
    end
  end
end
