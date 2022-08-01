# frozen_string_literal: true

Given('I am on the Request Form page') do
  sign_in_user
  mock_api_response
  visit la_request_index_path
end

Given('I am on the Request Form page and can only upload for 1 LA') do
  sign_in_user
  mock_single_la_api_response
  visit la_request_index_path
end

When('I enter valid parameters') do
  fill_name('Joe Bloggs')
  fill_valid_email('joe.bloggs@informed.com')
  fill_details('I need to reset my password')
end

When('I enter no parameters') do
  fill_name('')
  fill_valid_email('')
  fill_details('')
end

Then('I press Confirm and send button') do
  allow(AWS_SQS).to receive(:send_message).and_return(true)
  click_button 'Confirm and send'
end

private

def fill_name(name_value = name)
  fill_in('name', with: name_value)
end

def fill_valid_email(email_value = email)
  fill_in('email', with: email_value)
end

def fill_details(details_value = details)
  fill_in('details', with: details_value)
end

def mock_api_response
  allow(AuthorityApi).to receive(:licensing_authorities).and_return(%w[Birmingham Leeds])
end

def mock_single_la_api_response
  allow(AuthorityApi).to receive(:licensing_authorities).and_return(%w[Leeds])
end
