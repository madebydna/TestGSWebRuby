# frozen_string_literal: true

class GkVocabularyMilestones < SitePrism::Page
  set_url_matcher(/\/gk\/category\/milestones-topics\/vocabulary\//)
  element :heading, 'h1'
  elements :videos, '.thumbnail'
end
