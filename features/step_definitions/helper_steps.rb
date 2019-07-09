# frozen_string_literal: true

Then('I should see {string}') do |string|
  expect(page).to have_content(string)
end

Then('I should see {string} title') do |string|
  expect(page).to have_title(string)
end

Then('I press the Continue') do
  click_button 'Continue'
end

def sign_in_user
  visit new_user_session_path
  fill_in('user_email', with: 'user@example.com')
  fill_in('user_password', with: '12345678')

  RSpec::Mocks.with_temporary_scope do
    expect_any_instance_of(Aws::CognitoIdentityProvider::Client).to receive(:initiate_auth)
      .and_return(true)

    click_button 'Continue'
  end
end
