# frozen_string_literal: true

class GkHomePage < SitePrism::Page
  set_url_matcher(/\/gk\//)
  element :heading, 'h1'
  elements :subheadings, '.sub-header'
  section :cue_cards, '.cue-card-module-horizontal-container' do

  end
  section :recommended_articles, 'section', text: 'Recommended Articles' do
    elements :content_tiles, '.content-tile'
  end

  section :newsletter_signup_section, 'section.newsletter-horizontal-container' do

  end

  section :footer, '#footer' do

  end
end
