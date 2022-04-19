# frozen_string_literal: true

require 'rails_helper'

describe CsvUploadService do
  subject(:service_call) { described_class.call(file:, user:) }

  let(:file) { fixture_file_upload(csv_file("#{filename}.csv")) }
  let(:filename) { 'CAZ-2020-01-08-AuthorityID' }
  let(:user) { create_user(sub:) }
  let(:sub) { SecureRandom.uuid }

  describe '#call' do
    context 'with valid params' do
      before do
        mock = instance_double(Aws::S3::Object, upload_file: true)
        allow(Aws::S3::Object).to receive(:new).and_return(mock)
      end

      context 'lowercase extension format' do
        let(:file) { fixture_file_upload(csv_file("#{filename}.csv")) }

        it 'returns an instance' do
          expect(subject).to be_an_instance_of(described_class)
        end

        it 'returns the proper file name' do
          freeze_time { expect(subject.filename).to eq("#{filename}_#{sub}_#{Time.current.to_i}.csv") }
        end
      end

      context 'uppercase extension format' do
        let(:file) { fixture_file_upload(csv_file("#{filename}.CSV")) }

        it 'returns an instance' do
          expect(subject).to be_an_instance_of(described_class)
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
          mock = instance_double(Aws::S3::Object, upload_file: false)
          allow(Aws::S3::Object).to receive(:new).and_return(mock)
        end

        it 'raises exception' do
          expect { service_call }.to raise_exception(CsvUploadFailureException)
        end
      end

      context 'when S3 raises an exception' do
        before { stub_request(:put, //).to_return(status: 500, body: '') }

        it 'raises a proper exception' do
          expect { service_call }.to raise_exception(CsvUploadFailureException)
        end
      end

      context 'when file size is too big' do
        let(:file) { fixture_file_upload(csv_file("#{filename}.csv")) }

        before { allow(file).to receive(:size).and_return(52_428_801) }

        it 'raises exception' do
          expect { service_call }.to raise_exception(CsvUploadFailureException)
        end
      end
    end
  end

  describe 'name format regexp' do
    subject(:regexp) { described_class::NAME_FORMAT }

    it { is_expected.to match('CAZ-2018-01-08-leeds') }
    it { is_expected.to match('CAZ-2018-01-08-leed3434') }
    it { is_expected.to match('CAZ-2018-01-08-1234') }

    it { is_expected.not_to match('CAZ-2018-01-08-leeds%@&') }
    it { is_expected.not_to match('cCAZ-2018-01-08-leeds') }
    it { is_expected.not_to match('cAZ-2018-01-08-leeds-') }
    it { is_expected.not_to match('CAZ-01-08-2020-Leeds') }
    it { is_expected.not_to match('CAZ-2018-01-08-leedsf-') }
    it { is_expected.not_to match('CAZ-leeds-2018-01-08') }
  end

  def csv_file(filename)
    File.join('spec', 'fixtures', 'files', 'csv', filename)
  end
end
