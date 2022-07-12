# frozen_string_literal: true

require 'rails_helper'

describe JsonWebToken::Decode do
  subject(:service_call) { described_class.call(token:) }

  let(:token) { JsonWebToken::Encode.call(payload:) }
  let(:payload) { { 'email' => 'example@example.com', 'exp' => expired, 'pw-reset-requested' => '11-11-2011' } }
  let(:expired) { (DateTime.current + 1.day).to_i }

  context 'with valid JWT' do
    it 'returns expected email' do
      expect(service_call['email']).to eq('example@example.com')
    end

    it 'returns expected exp' do
      expect(service_call['exp']).to eq(expired)
    end

    it 'returns expected pw-reset-requested' do
      expect(service_call['pw-reset-requested']).to eq('11-11-2011')
    end
  end

  context 'with invalid JWT' do
    let(:token) { 'RandomString' }

    it 'throws exception' do
      expect { service_call }.to raise_exception(JWT::DecodeError)
    end
  end
end
