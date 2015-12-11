require_relative 'header_section'
require_relative './modules/breadcrumbs'
require_relative './modules/gs_rating'
require_relative '../pages/modules/modals'

class SchoolProfileOverviewPage < SitePrism::Page
  include Breadcrumbs
  include GSRating
  include Modals

  set_url_matcher /#{States.any_state_name_regex}\/[a-zA-Z\-.]+\/[0-9]+-[a-zA-Z\-.]+\/$/

  element :profile_navigation, '#navigation2'
  section :header, HeaderSection, '.navbar-static'
  element :write_a_review_button, 'button', text: 'Write a review'

  section :reviews_section, '#reviews-section', visible: false do
    element :bar_chart, '.horizontal-bar-chart'
    elements :reviews, '.compact-review-module'
    element :ad_slot, '.gs_ad_slot'
    element :callout_text, 'div', text: 'Is there someone at this school who you want to say "thanks" to?'
    element :callout_button, 'button', text: 'Tell us about it'

    def click_on_callout_button
      callout_button.click
    end

    def show
      page.execute_script('$("#reviews-section").removeClass("dn");')
    end
  end

  element :contact_this_school_header, 'h2', text:'Contact this school'

  element :contact_this_school_content, 'div.contact-content'


  section :contact_this_school_map_section, 'div.contact-content:first-of-type + div' do
    element :school_map, 'img.contact-map-image'
  end

  section :media_gallery, 'h2', text: 'Media Gallery' do
    element :placeholder_image, 'img[alt="Media missing"]'
  end

  def click_on_write_a_review_button
    write_a_review_button.click
  end
end
