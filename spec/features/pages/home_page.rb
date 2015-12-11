require_relative './modules/join_modals'
require_relative './modules/flash_messages'

class HomePage < SitePrism::Page
  include EmailJoinModal
  include FlashMessages

  element :search_hero_section, 'h1', text: 'Welcome to GreatSchools'
  element :browse_by_city_section, 'h3', text: 'Browse by city'
  section :email_signup_section, '.js-shared-email-signup' do
    element :submit_button, '.hidden-xs button', text: 'Sign up'
  end
  element :greatkids_articles_section, 'h2', text: 'Set your child up for success!' # See FactoryGirl external_content.rb
  section :offers_section, '.rs-offers-section' do
    element :for_families_link, 'a', text: 'For families'
    element :for_schools_link, 'a', text: 'For schools'
    element :write_a_review_link, 'a', text: 'Write a review'
    element :search_by_address_link, 'a', text: 'Search by address'
  end
  element :quote_section, '.rs-quote-section'
  element :who_we_are_section, 'h2', text: 'Who we are'
  element :our_supporters_section, 'h2', text: 'Our supporters'
  element :common_core_banner_section, 'h2', text: 'GreatKids State Test Guide for Parents'

end