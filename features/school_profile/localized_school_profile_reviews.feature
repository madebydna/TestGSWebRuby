Feature: Localized Profile Reviews
  As a user
  I can view and write reviews
  So that I can evaluate and share my opinion on schools

  Background: 
    Given I visit a localized school profile reviews page

@javascript
Scenario: There are school reviews
  Given I see the reviews list

@javascript
Scenario: I can filter school reviews
  Given I filter on parents

