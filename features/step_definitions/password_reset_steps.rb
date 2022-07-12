# frozen_string_literal: true

def username
  'example@example.com'
end

def token
  'secretToken'
end

Given('I am on the forgotten password page') do
  visit reset_passwords_path
end

When('I enter my username') do
  allow(Cognito::ForgotPassword::InitiateReset)
    .to receive(:call)
    .with(username:)
    .and_return(true)
  fill_in('user[username]', with: username)
  click_button 'Reset password'
end

Then("I am taken to the 'Reset link sent' page") do
  expect(page.current_url).to eq(email_send_passwords_url)
end

Given("I am on the 'Confirm reset password' page") do
  allow(Cognito::ForgotPassword::ConfirmResetValidator)
    .to receive(:call)
    .and_return([username, token])
  visit confirm_reset_passwords_path
end

When('I enter valid passwords') do
  password = 'p@ssword!'
  allow(Cognito::ForgotPassword::ChangePassword)
    .to receive(:call).with(
      username:,
      password:,
      password_confirmation: password,
      token:
    ).and_return(true)
  fill_in('user[password]', with: password)
  fill_in('user[password_confirmation]', with: password)
  click_button 'Update password'
end

When('I enter invalid email') do
  fill_in('user[username]', with: 'wojtek')
  click_button 'Reset password'
end

Then('I remain on the update password page') do
  expect(page).to have_current_path(reset_passwords_path)
end

And('I enter passwords that does not comply with Cognito setup password policy') do
  service = Cognito::ForgotPassword::ChangePassword
  allow(service).to receive(:call).and_raise(Cognito::CallException,
                                             { password: I18n.t('password.errors.complexity') }.to_json)
  fill_in('user[password]', with: 'password')
  fill_in('user[password_confirmation]', with: 'password')
end
