# frozen_string_literal: true

class GkHighSchoolMilestones < SitePrism::Page
  set_url '/gk/levels/high-school/'
  set_url_matcher(/\/gk\/levels\/high-school\//)
  element :heading, 'h1'
  elements :videos, '.thumbnail'
end
