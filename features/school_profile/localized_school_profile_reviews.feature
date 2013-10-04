Feature: Localized Profile Reviews
  As a user
  I can view and write reviews
  So that I can evaluate and share my opinion on schools

  Background: 
    Given I visit localized school profile reviews page

  @javascript
  Scenario: There are school reviews
    Given I see reviews

  @javascript
  Scenario Outline: I can filter school reviews
    Given I filter on <filter>
  Examples:
    | filter    |
    | parents   |
    | students  |
    | all       |

  @javascript
  Scenario: I can filter school reviews
    When I visit a school with more than ten reviews
    And I click the button "Get Next Ten"
    Then I wait to see more than ten reviews

