# frozen_string_literal: true

require 'rails_helper'

describe 'UploadController - POST #import', type: :request do
  subject { post import_upload_index_path, params: { file: csv_file } }

  let(:csv_file) { fixture_file_upload(file_path) }
  let(:file_path) { File.join('spec', 'fixtures', 'files', 'csv', 'CAZ-2020-01-08-AuthorityID.csv') }
  let(:filename) { 'CAZ-2020-01-08-AuthorityID_1431a5ea-1048-446e-b4c8-2151e333e96f_1633598919.csv' }

  before { sign_in create_user }

  context 'with valid params' do
    let(:job_name) { 'name' }

    before do
      stub = instance_double(CsvUploadService, filename: filename)
      allow(CsvUploadService).to receive(:call).and_return(stub)
      allow(RegisterCheckerApi).to receive(:register_job).and_return(job_name)
      subject
    end

    it 'returns a success response' do
      expect(response).to have_http_status(:found)
    end

    it 'sets job name in session' do
      expect(session[:job][:name]).to eq(job_name)
    end

    it 'sets filename in session' do
      expect(session[:job][:filename]).to eq(filename)
    end
  end

  context 'with invalid params' do
    let(:file_path) do
      File.join('spec',
                'fixtures', 'files', 'csv', 'empty', 'сAZ-2020-01-08-AuthorityID.csv')
    end

    it 'returns error' do
      subject
      follow_redirect!
      expect(response.body).to include('The selected file must be named correctly')
    end
  end
end
