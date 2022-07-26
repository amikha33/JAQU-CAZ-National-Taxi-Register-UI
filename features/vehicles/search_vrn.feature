Feature: Search a VRN
  In order to read the page
  As a user
  I want to search a vrn

  Scenario: Search a VRN
    Given I am on the Search VRN page
    When I press 'Continue' button
    Then I should see 'Enter the number plate of the vehicle'
      And I should see 'Choose a search type'
    When I enter a vrn 'CU57ABC '
      And I press 'Continue' button
    Then I should see "You searched for CU57ABC"

  Scenario: Search VRN in an invalid format
    Given I am on the Search VRN page
      And I enter an invalid vrn format
      And I press 'Continue' button
    Then I should see 'Enter the number plate of the vehicle in a valid format'

  Scenario: VRN not found
    Given I am on the Search VRN page
      And I enter a vrn which not exists in database
      And I press 'Continue' button
    Then I should be on the Results not found page

  Scenario: Server is unavailable
    Given I am on the Search VRN page
      And I enter a vrn when server is unavailable
      And I press 'Continue' button
    Then I should see 'Sorry, the service is unavailable' title

  Scenario: Search a VRN for historical results
    Given I am on the Search VRN page
      And I should see "Search the Taxi & PHV Data"
    When I enter a vrn and choose Search for historical results
      And I press 'Continue' button
    Then I should see 'Start date must include a day, month and year'
      And I should see 'End date must include a day, month and year'
    Then I enter a vrn and invalid dates format
      And I press 'Continue' button
    Then I should see 'Start date must be a real date'
    When I enter a vrn and start date earlier than end date
      And I press 'Continue' button
      And I should see 'Start date must be earlier than end date'
    Then I enter a vrn and valid dates format
      And I press 'Continue' button
    Then I should see 'Results for CU57ABC'

  Scenario: Search a VRN for historical results with Invalid date
    Given I am on the Search VRN page
      And I should see "Search the Taxi & PHV Data"
    When I enter a vrn and negative start date
      And I press 'Continue' button
    Then I should see 'Enter a valid date'
    When I enter a vrn and negative end date
      And I press 'Continue' button
    Then I should see 'Enter a valid date'

  # Order of calling pages: 1, 3, 5, 2
  Scenario: Pagination on the historical results page
  Given I am on the Historical results page
    And I should be on the Search results
    Then I should see active "1" pagination button
    And I should not see "previous" pagination button
  Then I go the Search vehicles results page
     And I should see active "1" pagination button
  Then I go the Search vehicles results page
    And I press 3 pagination button
    And I should be on the Search results page number 3
    And I should see active "3" pagination button
  Then I press 5 pagination button
    And I should be on the Search results page number 5
    And I should see active "5" pagination button
    And I should not see "next" pagination button
  Then I press 2 pagination button
    And I should be on the Search results page number 2
    And I should see active "2" pagination button
    And I should see inactive "1" pagination button

  Scenario: Historical Search when no results found
    Given I am on the Search VRN page
    Then I enter a vrn without history and valid dates format
      And I press 'Continue' button
    Then I should see 'There is no historical data for CU57ABC'
      And I should not see "Date modified"

  Scenario: Sign in and not belongs to any Cognito group
    Given I am signed and not belongs to any group
      And I should not see 'Search' link
    When I navigate to a Search vehicles page
    Then I should be on the Service Unavailable page
