FactoryGirl.define do

# Basic solr response with doc with schools results
  factory :solr_response_object, class:Hash do
    responseHeader FactoryGirl.build(:solr_response_header)
    response FactoryGirl.build(:solr_response)

    initialize_with { attributes.stringify_keys }
  end

# Solr response with doc with nearby cities results
  factory :solr_cities_response_object, class:Hash do
    responseHeader FactoryGirl.build(:solr_response_header)
    response { FactoryGirl.build(:solr_response_for_nearby_cities_search) }

    initialize_with { attributes.stringify_keys }
  end

# Solr response with doc with schools results for a name search for 'north'
  factory :solr_response_object_north_name_search, class:Hash do
    responseHeader FactoryGirl.build(:solr_response_header)
    response FactoryGirl.build(:solr_response_for_name_search_north)

    initialize_with { attributes.stringify_keys }
  end

# Solr response with doc with schools results for a name search for 'magnolia'
  factory :solr_response_object_magnolia_name_search, class:Hash do
    responseHeader FactoryGirl.build(:solr_response_header)
    response FactoryGirl.build(:solr_response_for_name_search_magnolia)

    initialize_with { attributes.stringify_keys }
  end

end
