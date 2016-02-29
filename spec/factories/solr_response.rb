FactoryGirl.define do

# solr doc hash with schools results
  factory :solr_response, class:Hash do
    numFound 125
    start 0
    docs FactoryGirl.build_list(:solr_school_result_hash, 125)

    initialize_with { attributes.stringify_keys }
  end

# solr doc hash with schools results for name search 'north'
  factory :solr_response_for_name_search_north, class:Hash do
    numFound 125
    start 0
    docs FactoryGirl.build_list(:solr_school_result_hash_north_name, 125)

    initialize_with { attributes.stringify_keys }
  end

# solr doc hash with schools results for name search 'magnolia'
  factory :solr_response_for_name_search_magnolia, class:Hash do
    numFound 125
    start 0
    docs FactoryGirl.build_list(:solr_school_result_hash_magnolia, 125)

    initialize_with { attributes.stringify_keys }
  end

# solr doc hash with nearby cities results
  factory :solr_response_for_nearby_cities_search, class:Hash do
    numFound 8
    start 0
    docs { FactoryGirl.build_list(:solr_city_result_hash, 2) }

    initialize_with { attributes.stringify_keys }
  end

end
