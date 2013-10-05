Feature: Localized Profile: View Reviews
  As a user
  I can see other parents' reviews

  Background: 
    Given I visit a localized school profile reviews page

  @javascript
  Scenario: There are school reviews
    Then I see reviews

  @javascript
  Scenario Outline: I can filter school reviews
    Then I filter on <filter>
  Examples:
    | filter    |
    | parents   |
    | students  |
    | all       |

  @javascript
  Scenario: I can pagination through reviews
    When I visit a school with more than ten reviews
    And I click the button "Get Next Ten"
    Then I wait to see more than 10 reviews

  @javascript
  Scenario Outline: I can sort reviews
    Then I sort reviews by <field>
  Examples:
  | field                   |
  | Date newest to oldest   |
  | Date oldest to newest   |
  | Ratings high to low     |
  | Ratings low to high     |

