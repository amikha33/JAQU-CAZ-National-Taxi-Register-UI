# frozen_string_literal: true

require 'rails_helper'

describe LaRequestDvlaMailer do
  subject(:mail) { described_class.call(session:) }

  let(:session) { { reference:, licensing_authorities:, name:, email:, details: } }
  let(:reference) { SecureRandom.hex(10) }
  let(:licensing_authorities) { 'Bradford; Leeds' }
  let(:name) { 'Joe Bloggs' }
  let(:email) { 'joe.bloggs@informed.com' }
  let(:details) { 'I need to reset my email address' }

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
