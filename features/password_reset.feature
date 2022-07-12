Feature: Password reset
  As a Licensing Authority
  I want to be able to reset my password
  So that I may still upload to the National Taxi register, even if I forget my password

  Scenario: Go to forgotten password page
    Given I am on the Sign in page
    When I press "Forgot your password?" link
    Then I should see "Enter your email to reset password"

  Scenario: Go to update password page
    Given I am on the forgotten password page
    When I enter my username
    Then I am taken to the 'Reset link sent' page

  Scenario: Filling update password form
    Given I am on the 'Confirm reset password' page
    When I enter valid passwords
    Then I am taken to Password set successfully page

  Scenario: Filling invalid email format
    Given I am on the forgotten password page
    When I enter invalid email
    Then I remain on the update password page
      And I should see "Enter your email address in a valid format"

  Scenario: Filling invalid passwords
    Given I am on the 'Confirm reset password' page
    When I enter passwords that does not comply with Cognito setup password policy
      And I press 'Update password' button
      And I should see 'Enter a password at least 8 characters long, including at least one upper case letter and number' 2 times
