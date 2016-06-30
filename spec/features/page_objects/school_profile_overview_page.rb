require 'features/page_objects/header_section'
require 'features/page_objects/modules/breadcrumbs'
require 'features/page_objects/modules/gs_rating'
require 'features/page_objects/modules/modals'
require 'features/page_objects/modules/school_profile_page'
require 'features/page_objects/modules/footer'

class SchoolProfileOverviewPage < SitePrism::Page
  include Breadcrumbs
  include GSRating
  include Modals
  include SchoolProfilePage
  include Footer

  set_url_matcher /#{States.any_state_name_regex}\/[a-zA-Z\-.]+\/[0-9]+-[a-zA-Z\-.]+\/$/

  section :header, HeaderSection, '.navbar-static'
  element :write_a_review_button, 'button', text: 'Write a review'
  element :apply_now_button, 'button', text: 'Apply now'

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

  section :facebook_section, '#facebook-section' do
    element :facebook_module_heading, 'h2', text:'Facebook'
  end

  element :contact_this_school_header, 'h2', text:'Contact this school'

  element :contact_this_school_content, 'div.contact-content'


  section :contact_this_school_map_section, 'div.contact-content:first-of-type + div' do
    element :school_map, 'img.contact-map-image'
  end

  section :media_gallery, 'h2', text: 'Media Gallery' do
    element :placeholder_image, 'img[alt="Media missing"]'
  end

  section :gs_rating , 'overall-gs-rating' do

  end


  element :zillow_header, 'h2', text:'Nearby homes and rentals'

  element :zillow_content, 'div.gs-zillow-module'


  section :quick_links , 'div.quick-links' do

  end

  def click_on_write_a_review_button
    write_a_review_button.click
  end
end
