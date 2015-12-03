require_relative 'header_section'
require_relative './modules/breadcrumbs'
require_relative './modules/gs_rating'

class SchoolProfileOverviewPage < SitePrism::Page
  include Breadcrumbs
  include GSRating

  set_url_matcher /#{States.any_state_name_regex}\/[a-zA-Z\-.]+\/[0-9]+-[a-zA-Z\-.]+\/$/

  element :profile_navigation, '#navigation2'
  section :header, HeaderSection, '.navbar-static'
  element :write_a_review_button, 'button', text: 'Write a review'

  section :reviews_section, '#reviews-section' do
    element :bar_chart, '.horizontal-bar-chart'
    elements :reviews, '.compact-review-module'
    element :ad_slot, '.gs_ad_slot'
    element :callout_text, 'div', text: 'Is there someone at this school who you want to say "thanks" to?'
    element :callout_button, 'button', text: 'Tell us about it'
  end

  def click_on_write_a_review_button
    write_a_review_button.click
  end
end
