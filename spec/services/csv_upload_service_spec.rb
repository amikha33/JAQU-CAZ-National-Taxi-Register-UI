# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CsvUploadService do
  subject(:service_call) { described_class.call(file: file) }

  let(:file) { fixture_file_upload(file_fixture('CAZ-2020-01-08-AuthorityID-4321.csv')) }

  describe '#call' do
    context 'with valid params' do
      before do
        allow_any_instance_of(Aws::S3::Object).to receive(:upload_file).and_return(true)
      end

      it 'returns true' do
        expect(service_call).to be true
      end

      context 'lowercase extension format' do
        let(:file) { fixture_file_upload(file_fixture('CAZ-2020-01-08-AuthorityID-4321.csv')) }

        it 'returns true' do
          expect(service_call).to be true
        end
      end

      context 'uppercase extension format' do
        let(:file) { fixture_file_upload(file_fixture('CAZ-2020-01-08-AuthorityID-4321.CSV')) }

        it 'returns true' do
          expect(service_call).to be true
        end
      end
    end

    context 'with invalid params' do
      context 'when `ValidateCsvService` returns error' do
        let(:file) { nil }

        it 'raises exception' do
          expect { service_call }.to raise_exception(CsvUploadFailureException)
        end
      end

      context 'when `S3UploadService` returns error' do
        before do
          allow_any_instance_of(Aws::S3::Object).to receive(:upload_file).and_return(false)
        end

        it 'raises exception' do
          expect { service_call }.to raise_exception(CsvUploadFailureException)
        end
      end
    end
  end
end