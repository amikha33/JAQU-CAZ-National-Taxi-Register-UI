# frozen_string_literal: true

require 'rails_helper'

describe Ses::SendSuccessEmail do
  subject(:service_call) { described_class.call(user: user, job_data: job_data) }

  let(:user) { create_user(email: email) }
  let(:email) { 'user@example.com' }
  let(:job_data) { { filename: filename, submission_time: time } }
  let(:filename) { 'CAZ-2020-01-08-AuthorityID.csv' }
  let(:time) { Time.current.strftime(Rails.configuration.x.time_format) }

  context 'with valid params' do
    before do
      mailer = Struct.new(:deliver).new(true)
      allow(UploadMailer).to receive(:success_upload).and_return(mailer)
    end

    it { is_expected.to be_truthy }

    it 'sends an email with proper params' do
      service_call
      expect(UploadMailer).to have_received(:success_upload).with(user, filename, time)
    end
  end

  context 'with invalid params' do
    before { allow(UploadMailer).to receive(:success_upload) }

    context 'when user email is missing' do
      let(:email) { '' }

      it { is_expected.to be_falsey }

      it 'does not call UploadMailer' do
        service_call
        expect(UploadMailer).not_to have_received(:success_upload)
      end
    end

    context 'when filename is missing' do
      let(:filename) { nil }

      it { is_expected.to be_falsey }

      it 'does not call UploadMailer' do
        service_call
        expect(UploadMailer).not_to have_received(:success_upload)
      end
    end

    context 'when submission time is missing' do
      let(:time) { nil }

      it { is_expected.to be_falsey }

      it 'does not call UploadMailer' do
        service_call
        expect(UploadMailer).not_to have_received(:success_upload)
      end
    end
  end

  context 'when sending emails fails' do
    before do
      allow(UploadMailer).to receive(:success_upload).and_raise(
        Aws::SES::Errors::MessageRejected.new('', 'error')
      )
    end

    it { is_expected.to be_falsey }
  end
end
