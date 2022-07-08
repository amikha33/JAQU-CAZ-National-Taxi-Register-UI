# frozen_string_literal: true

require 'rails_helper'

describe CsvUploadMailer do
  subject(:mail) { described_class.call(email:, job_data:) }

  let(:email) { 'user@example.com' }
  let(:job_data) { { filename:, submission_time: time } }
  let(:filename) { 'CAZ-2020-01-08-AuthorityID.csv' }
  let(:time) { Time.current.strftime(Rails.configuration.x.time_format) }

  context 'when Cognito call is ok' do
    before { allow(AWS_SQS).to receive(:send_message) }

    it 'returns a proper value' do
      expect(subject).to eq(44)
    end
  end

  context 'when Cognito call fails' do
    before do
      exception = Aws::SQS::Errors::ServiceError.new('', '')
      allow(AWS_SQS).to receive(:send_message).and_raise(exception)
    end

    it 'returns false' do
      expect(subject).to be(false)
    end
  end
end
