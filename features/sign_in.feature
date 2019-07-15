Feature: Sign In
  In order to read the page
  As a Licensing Authority
  I want to see the upload page

  Scenario: View upload page without cookie
    Given I have no authentication cookie
    When I navigate to a Upload page
    Then I am redirected to the Sign in page
      And I should see "Sign In"
      And I should see "Centralised Taxi and PHV Data Maintenance" title
    Then I should enter valid credentials and press the Continue
    When I should see "Taxi/PHV Data Upload"
      And Cookie is created for my session

  Scenario: View upload page with cookie that has not expired
    Given I have authentication cookie that has not expired
    When I navigate to a Upload page
    Then I am redirected to the Upload page
      And I should see "Taxi/PHV Data Upload"

  Scenario: View upload page with cookie that has expired
    Given I have authentication cookie that has expired
    When I navigate to a Upload page
    Then I am redirected to the Sign in page
      And I should see "Sign In"

  Scenario: Sign in with invalid credentials
    Given I am on the Sign in page
    When I enter invalid credentials
    Then I remain on the current page
      And I should see "The username or password you entered is incorrect"

  Scenario: Sign out
    Given I am signed in
    When I request to sign out
    Then I am redirected to the Sign in page
    When I navigate to a Upload page
    Then I am redirected to the Sign in page
      And I should see "Sign In"