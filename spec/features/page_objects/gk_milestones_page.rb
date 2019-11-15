# frozen_string_literal: true

class GkMilestones < SitePrism::Page
  set_url '/gk/milestones/'
  set_url_matcher(/\/gk\/milestones\//)
  element :heading, 'h1'
  elements :grade_nav_circles, '.grade-nav-circle'
end
