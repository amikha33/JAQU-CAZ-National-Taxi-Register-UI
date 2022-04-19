# frozen_string_literal: true

def correlation_id
  SecureRandom.uuid
end

def job_name
  'ae67c64a-1d9e-459b-bde0-756eb73f36fe'
end

# Scenario: Upload a csv file and redirect to processing page
When('I upload a valid csv file') do
  allow(SecureRandom).to receive(:uuid).and_return(correlation_id)
  filename = 'CAZ-2020-01-08-AuthorityID-08_1431a5ea-1048-446e-b4c8-2151e333e96f_1633598919.csv'
  stub = instance_double(CsvUploadService, filename:)
  allow(CsvUploadService).to receive(:call).and_return(stub)
  allow(RegisterCheckerApi).to receive(:register_job).with(filename, correlation_id).and_return(job_name)
  allow(RegisterCheckerApi).to receive(:job_status).with(job_name, correlation_id).and_return('RUNNING')

  attach_file(:file, csv_file('CAZ-2020-01-08-AuthorityID.csv'))
  click_button 'Upload'
end

When('I press refresh page link') do
  allow(RegisterCheckerApi).to receive(:job_status)
    .with(job_name, correlation_id).and_return('SUCCESS')

  click_link 'click here'
end

Then('I am redirected to the Success page') do
  expect(page).to have_current_path(success_upload_index_path)
end

Then('I receive a success upload email') do
  expect(ActionMailer::Base.deliveries.size).to eq(1)
end

Then('I should not receive a success upload email again') do
  expect(ActionMailer::Base.deliveries.size).to eq(1)
end

# Scenario: Upload a csv file and redirect to error page when api response not running or finished
When('I press refresh page link when api response not running or finished') do
  allow(RegisterCheckerApi).to receive(:job_status)
    .with(job_name, correlation_id).and_return('FAILURE')
  allow(RegisterCheckerApi).to receive(:job_errors)
    .with(job_name, correlation_id).and_return(%w[error])
  click_link 'click here'
end

#  Scenario: Upload a csv file whose name is not compliant with the naming rules
When('I upload a csv file whose name format is invalid #1') do
  attach_file(:file, empty_csv_file('сAZ-2020-01-08-AuthorityID.csv'))
  click_button 'Upload'
end

When('I upload a csv file whose name format is invalid #2') do
  attach_file(:file, empty_csv_file('CAZ-01-08-2020-AuthorityID.csv'))
  click_button 'Upload'
end

When('I upload a csv file whose name format is invalid #3') do
  attach_file(:file, empty_csv_file('CAZ-2020-01-.csv'))
  click_button 'Upload'
end

When('I upload a csv file whose name format is invalid #4') do
  attach_file(:file, empty_csv_file('CAZ-2020-01-08-AuthorityID-.csv'))
  click_button 'Upload'
end

When('I upload a csv file whose name format is invalid #5') do
  attach_file(:file, empty_csv_file('CAZ-2020-01-08-Auth_orityID.csv'))
  click_button 'Upload'
end

When('I upload a csv file whose name format is invalid #6') do
  attach_file(:file, empty_csv_file('cCAZ-2020-01-08-AuthorityID.CSV'))
  click_button 'Upload'
end

# Scenario: Upload a csv file format that is not .csv or .CSV
When('I upload a csv file whose format that is not .csv or .CSV') do
  attach_file(:file, empty_csv_file('CAZ-2020-01-08-AuthorityID.xlsx'))
  click_button 'Upload'
end

# Scenario: Upload a csv file whose size is too big
When('I upload a csv file whose size is too big') do
  attach_file(:file, csv_file('CAZ-2020-01-08-AuthorityID.csv'))
  allow_any_instance_of(ActionDispatch::Http::UploadedFile).to receive(:size)
    .and_return(52_428_801)
  click_button 'Upload'
end

# Upload a valid csv file during error is encountered writing to S3
When('I upload a csv file during error on S3') do
  allow_any_instance_of(Aws::S3::Object).to receive(:upload_file).and_return(false)

  attach_file(:file, csv_file('CAZ-2020-01-08-AuthorityID.csv'))
  click_button 'Upload'
end

# Scenario: Show processing page without uploaded csv file
When('I want go to processing page') do
  visit processing_upload_index_path
end

Then('I change my IP') do
  allow_any_instance_of(ActionDispatch::Request)
    .to receive(:remote_ip)
    .and_return('4.3.2.1')
end

def empty_csv_file(filename)
  File.join('spec', 'fixtures', 'files', 'csv', 'empty', filename)
end

def csv_file(filename)
  File.join('spec', 'fixtures', 'files', 'csv', filename)
end
