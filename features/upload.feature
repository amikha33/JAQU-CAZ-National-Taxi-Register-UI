Feature: Upload
  In order to read the page
  As a Licensing Authority
  I want to upload a CSV file

  Scenario: Upload without file
    Given I am on the Upload page
    When I press "Upload" button
    Then I should see "Select a CSV file to upload"

  Scenario: Upload a csv file and redirect to processing page
    Given I am on the Upload page
    When I upload a valid csv file
    Then I should see "Validating submission"
      And I should see "If the page does not refresh automatically in 30 seconds click here."
    When I press refresh page link
    Then I am redirected to the Success page
      And I should see "Upload successful"

  Scenario: Upload a csv file and redirect to error page when api response not running or finished
    Given I am on the Upload page
    When I upload a valid csv file
    Then I should see "Validating submission"
      And I should see "If the page does not refresh automatically in 30 seconds click here."
    When I press refresh page link when api response not running or finished
    Then I am redirected to the Upload page
      And I should see "There was a problem"
      And I should see "Uploaded file is not valid"

  Scenario: Upload a csv file whose name is not compliant with the naming rules
    Given I am on the Upload page
    When I upload a csv file whose name format is invalid #1
    Then I should see "The selected file must be named correctly"
    When I upload a csv file whose name format is invalid #2
    Then I should see "The selected file must be named correctly"
    When I upload a csv file whose name format is invalid #3
    Then I should see "The selected file must be named correctly"
    When I upload a csv file whose name format is invalid #4
    Then I should see "The selected file must be named correctly"
    When I upload a csv file whose name format is invalid #5
    Then I should see "The selected file must be named correctly"
    When I upload a csv file whose name format is invalid #6
    Then I should see "The selected file must be named correctly"

  Scenario: Upload a csv file format that is not .csv or .CSV
    Given I am on the Upload page
    When I upload a csv file whose format that is not .csv or .CSV
    Then I should see "The selected file must be a CSV"

  Scenario: Upload a csv file whose size is too big
    Given I am on the Upload page
    When I upload a csv file whose size is too big
    Then I should see "The CSV must be smaller than 50MB"

  Scenario: Upload a valid csv file during error is encountered writing to S3
    Given I am on the Upload page
    When I upload a csv file during error on S3
    Then I should see "The selected file could not be uploaded – try again"

  Scenario: Show processing page without uploaded csv file
    Given I am on the Upload page
    When I want go to processing page
    Then I am redirected to the root page

  Scenario: User wants to upload CSV using different IP address
    Given I am on the Upload page
    Then I change my IP
      And I upload a valid csv file
    Then I should be on the login page
