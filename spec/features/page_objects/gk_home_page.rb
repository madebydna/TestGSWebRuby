# frozen_string_literal: true

require 'features/page_objects/modules/modals'

class GkHomePage < SitePrism::Page
  include Modals

  set_url_matcher(/\/gk\//)
  element :heading, 'h1'
  elements :subheadings, '.sub-header'
  section :cue_cards, '.cue-card-module-horizontal-container' do

  end
  section :recommended_articles, 'section', text: 'Recommended Articles' do
    elements :content_tiles, '.content-tile'
  end

  section :newsletter_signup_section, 'section.newsletter-horizontal-container' do
    element :sign_up_button, 'a', text: 'Sign up'
  end

  def sign_up_for_newsletters
    newsletter_signup_section.sign_up_button.click
    wait_for_email_newsletter_modal(15)
    email_newsletter_modal.sign_up("ssprouse@greatschools.org")
    # email_newsletter_modal.sign_up("ssprouse+rspec_#{Time.now.strftime('%<seconds>s%<ms>L')}@greatschools.org")
    wait_for_newsletter_success_modal(15)
  end

  section :footer, '#footer' do

  end
end
