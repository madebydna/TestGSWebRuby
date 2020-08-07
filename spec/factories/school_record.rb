FactoryBot.define do
  factory :school_record do
    # Workaround b/c FactoryBot thinks state and state_id are connected
    # and denote AR associations
    transient do
      state_id { "01611190130229" }
      state { "CA" }
    end

    after(:build) do |item, evaluator|
      item.state_id = evaluator.state_id
      item.state = evaluator.state
    end

    school_id 1
    city 'Alameda'
    county 'Alameda'
    FIPScounty 6001
    fax '(510) 521-4740'
    home_page_url 'http://aus.alamedausd.ca.schoolloop.com/'
    lat 37.7643
    lon (-122.2481)
    level '9,10,11,12'
    level_code 'h'
    name 'Alameda High School'
    nces_code '060177000041'
    phone '(510) 337-7022'
    geo_state 'CA'
    street '2201 Encinal Avenue'
    type 'public'
    subtype 'secondary'
    created '2013-11-14 18:34:53'
    modified '2013-11-14 18:34:53'
  end
end