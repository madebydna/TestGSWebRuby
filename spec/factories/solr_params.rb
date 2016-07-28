FactoryGirl.define do

  factory :solr_params, class:Hash do
    rows 100

    initialize_with { attributes.stringify_keys }
  end

  factory :city_browse_solr_params_dover_schools, class:Hash do
    rows 100
    fq ["+document_type:school", "+citykeyword:\"dover\"", "+school_database_state:\"de\""]
    query "*"
    sort "overall_gs_rating desc"
    start 0

    initialize_with { attributes }
  end

  factory :city_browse_solr_params_dover_nearby_cities, class:Hash do
    query "{!cityspatial circles=41.0882,-85.1439,80.0}"
     rows 8
     sort "distance asc"
     fq ["-city_keyword:\"dover\"", "+document_type:city", "+city_state:de"]
     qt "city-search"

    initialize_with { attributes }
  end

  factory :by_name_solr_params_dover_schools, class:Hash do

    rows 100
    fq ["+document_type:school", "+school_database_state:\"de\""]
    qt "school-search"
    query "+dover elementary"
    start 0
    spellcheck true

    initialize_with { attributes }
  end

  factory :by_location_delaware_address_solr_params_schools, class:Hash do

    rows 100
    fq ["+document_type:school", "+school_database_state:\"de\""]
    qt "school-search"
    sort "overall_gs_rating desc"
    start 0
    query "{!spatial circles=39.752831,-75.588326,8.0}"

    initialize_with  { attributes }
  end

  factory :by_location_delaware_address_solr_params_nearby_cities, class:Hash do

    query "{!cityspatial circles=39.752831,-75.588326,80.0}"
    rows 8
    sort "distance asc"
    fq ["+document_type:city", "+city_state:de"]
    qt "city-search"

    initialize_with  { attributes }
  end


  factory :district_browse_delaware_solr_params_schools, class:Hash do

    rows 100
    query "*"
    fq ["+document_type:school", "+school_district_id:\"47\"", "+school_database_state:\"de\""]
    sort "overall_gs_rating desc"
    start 0

    initialize_with  { attributes }
  end

  factory :district_browse_delaware_solr_params_nearby_cities, class:Hash do

    query "{!cityspatial circles=47.0,47.0,80.0}"
    rows 8
    sort "distance asc"
    fq ["-city_keyword:\"odessa\"", "+document_type:city", "+city_state:de"]
    qt "city-search"

    initialize_with  { attributes }
  end

  factory :city_browse_ohio_solr_params_nearby_cities, class:Hash do

    query "{!cityspatial circles=41.0882,-85.1439,80.0}"
    rows 8
    sort "distance asc"
    fq ["-city_keyword:\"youngstown\"", "+document_type:city", "+city_state:oh"]
    qt "city-search"

    initialize_with  { attributes }
  end

  factory :city_browse_ohio_solr_params_schools, class:Hash do

    rows 100
    query "*"
    fq ["+document_type:school", "+citykeyword:\"youngstown\"", "+school_database_state:\"oh\""]
    sort "overall_gs_rating desc"
    start 0

    initialize_with  { attributes }
  end

  factory :by_name_solr_params_north, class:Hash do

    rows 100
    fq ["+document_type:school", "+school_database_state:\"de\""]
    qt "school-search"
    query "north"
    start 0
    spellcheck true

    initialize_with { attributes }
  end

  factory :by_name_solr_params_magnolia, class:Hash do
    rows 100
    fq ["+document_type:school", "+school_database_state:\"de\""]
    qt "school-search"
    query "+magnolia"
    start 0
    spellcheck true

    initialize_with { attributes }
  end
 end
