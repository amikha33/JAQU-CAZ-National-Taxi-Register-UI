# frozen_string_literal: true

require 'rails_helper'

describe 'AuthorityApi.licensing_authorities' do
  subject(:call) { AuthorityApi.licensing_authorities(uploader_id) }

  let(:uploader_id) { '5ab65846-1f24-42be-91c7-3325c9e8c237' }

  context 'when call returns a 200 OK status' do
    before do
      licensing_authorities = file_fixture('responses/authority_response.json').read
      stub_request(:get, /5ab65846-1f24-42be-91c7-3325c9e8c237/).to_return(status: 200, body: licensing_authorities)
    end

    it 'returns proper values' do
      expect(call).to eq(%w[Birmingham Leeds])
    end
  end

  context 'when call returns 500' do
    before do
      stub_request(:get, /5ab65846-1f24-42be-91c7-3325c9e8c237/).to_return(
        status: 500,
        body: { 'message' => 'Something went wrong' }.to_json
      )
    end

    it 'raises `Error500Exception`' do
      expect { call }.to raise_exception(BaseApi::Error500Exception)
    end
  end

  context 'when call returns 400' do
    before do
      stub_request(:get, /5ab65846-1f24-42be-91c7-3325c9e8c237/).to_return(
        status: 400,
        body: { 'message' => 'Correlation ID is missing' }.to_json
      )
    end

    it 'raises `Error400Exception`' do
      expect { call }.to raise_exception(BaseApi::Error400Exception)
    end
  end
end
