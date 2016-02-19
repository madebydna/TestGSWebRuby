FactoryGirl.define do
  factory :school_metadata_gs_rating_configuration, class: SchoolProfileConfiguration do
    state 'ca'
    configuration_key 'gs_rating'
    value({
      "overall" => {
        "use_gs_rating" => "true",
        "use_school_value_float" => "true",
        "description_key" => "what_is_basic_gs_rating_summary",
        "methodology_url_key" => "GS_rating_url",
        "default_methodology_url" => "http://www.greatschools.org/about/ratings.page"
      }
    }.to_json)
  end

  factory :school_cache_gs_rating_configuration, class: SchoolProfileConfiguration do
    state 'ca'
    configuration_key 'gs_rating'
    value({
      "overall" => {
        "data_type_id" => 174,
        "use_school_value_float" => "true",
        "description_key" => "what_is_basic_gs_rating_summary",
        "methodology_url_key" => "GS_rating_url",
        "default_methodology_url" => "http://www.greatschools.org/about/ratings.page"
      }
    }.to_json)
  end
end