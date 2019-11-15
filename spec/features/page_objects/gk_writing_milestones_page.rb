# frozen_string_literal: true

class GkWritingMilestones < SitePrism::Page
  set_url '/gk/category/milestones-subjects/writing/'
  set_url_matcher(/\/gk\/category\/milestones-subjects\/writing\//)
  element :heading, 'h1'
  elements :videos, '.thumbnail'

  section :sidebar, '#category-sidebar' do
    elements :links, 'li a'
  end
end
