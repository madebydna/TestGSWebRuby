Feature: Localized Profile: Sign in
  As a user
  I'd like to sign in to GreatSchools
  So I can access personalized content

  Background:
    Given I visit the localized signin page

  @javascript
  Scenario: I can see the signin form
    Then I see the signin form