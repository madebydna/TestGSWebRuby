class HomePage < SitePrism::Page
  element :search_hero_section, 'h1', text: 'Welcome to GreatSchools'
  element :browse_by_city_section, 'h3', text: 'Browse by city'
  element :email_signup_section, '.js-shared-email-signup'
  element :greatkids_articles_section, 'h2', text: 'Explore our new parenting site, GreatKids!'
  section :offers_section, '.rs-offers-section' do
    element :for_families_link, 'a', text: 'For families'
    element :for_schools_link, 'a', text: 'For schools'
    element :write_a_review_link, 'a', text: 'Write a review'
    element :search_by_address_link, 'a', text: 'Search by address'
  end
  element :quote_section, '.rs-quote-section'
  element :who_we_are_section, 'h2', text: 'Who we are'
  element :our_supporters_section, 'h2', text: 'Our supporters'
  element :sel_banner_section, 'h2', text: 'Introducing Emotional Smarts'

end