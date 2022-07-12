# frozen_string_literal: true

require 'rails_helper'

describe JsonWebToken::Encode do
  subject(:service_call) { described_class.call(payload:) }

  let(:payload) { 'example@example.com' }

  context 'successfuly encodes data' do
    it 'returns not empty response' do
      expect(service_call).not_to be_empty
    end

    it 'can be successfuly decoded with JsonWebToken::Decode service' do
      expect(JsonWebToken::Decode.call(token: service_call)).to eq(payload)
    end
  end
end
