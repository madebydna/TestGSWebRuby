Feature: Localized Profile: Sign in
  As a user
  I'd like to sign in to GreatSchools
  So I can access personalized content

  Background:
    Given I visit the localized signin page

  @javascript
  Scenario: I can see the signin form
    Then I see the signin form

  @javascript
  Scenario: Email is required
    When I click on the "Login" button
    Then I see the email required error

  @javascript
  Scenario: Email format is validated
    And I type "sldfjlfdslks" into the "email field"
    When I click on the "Login" button
    Then I see the email invalid error

  @javascript
  Scenario: Valid email is valid
    And I type "blah@greatschools.org" into the "email field"
    When I click on the "Login" button
    Then I don't see email errors

  @javascript
  Scenario:
    And I type "blah@greatschools.org" into the "email field"
    When I click on the "Login" button
    Then I don't see email errors


