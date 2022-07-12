# frozen_string_literal: true

require 'rails_helper'

describe ResetPasswordMailer do
  subject(:mail) { described_class.call(email:, jwt_token:) }

  let(:email) { 'user@example.com' }
  let(:jwt_token) { 'sometoken' }
  let(:time) { Time.current.strftime(Rails.configuration.x.time_format) }

  context 'when Cognito call is ok' do
    before { allow(AWS_SQS).to receive(:send_message) }

    it 'returns a proper value' do
      expect(subject).to eq(48)
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
