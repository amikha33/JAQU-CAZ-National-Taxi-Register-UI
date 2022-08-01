Feature: Submit a request
  In order make a support request
  As a LA user
  I want submit a request

  Scenario: Make valid request
    Given I am on the Request Form page
    When I enter valid parameters
    Then I press the Continue
      And I should see 'Check your answers'
      And I should see 'Licensing authorities'
      And I should see 'Birmingham, Leeds'
      And I should see 'Joe Bloggs'
      And I should see 'joe.bloggs@informed.com'
      And I should see 'I need to reset my password'
    Then I press Confirm and send button
      And I should see 'You have successfully submitted a request, a confirmation email has been sent.'

  Scenario: Make valid request with only 1 LA
    Given I am on the Request Form page and can only upload for 1 LA
    When I enter valid parameters
    Then I press the Continue
      And I should see 'Check your answers'
      And I should see 'Licensing authority'
      And I should see 'Leeds'
      And I should see 'Joe Bloggs'
      And I should see 'joe.bloggs@informed.com'
      And I should see 'I need to reset my password'
    Then I press Confirm and send button
      And I should see 'You have successfully submitted a request, a confirmation email has been sent.'

  Scenario: Make invalid request
    Given I am on the Request Form page
    When I enter no parameters
    Then I press the Continue
      And I should see 'There is a problem'
      And I should see 'Enter your full name'
      And I should see 'Enter your email address'
      And I should see 'Enter your request details'
