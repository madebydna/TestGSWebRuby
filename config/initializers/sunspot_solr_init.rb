# frozen_string_literal: true

Sunspot.config.solr.url = 'http://solr:8983/solr/main/' #ENV_GLOBAL['solr.ro.server.url']

Sunspot.setup(School) do
  string :sortable_name
  string :city
  integer :school_district_id
  string :school_district_name
  string :state
  integer :summary_rating
  string :level_codes
  integer :test_scores_rating

  Breakdown.unique_ethnicity_names.each do |breakdown|
    field_name = "test_scores_rating_#{breakdown.downcase.gsub(' ', '_')}"
    integer field_name
  end
  Breakdown.unique_socioeconomic_names.each do |breakdown|
    field_name = "test_scores_rating_#{breakdown.downcase.gsub(" ", "_")}"
    integer field_name
  end

  integer :academic_progress_rating
  integer :college_readiness_rating
  integer :advanced_courses_rating
  integer :equity_overview_rating

  latlon(:latlon) { Sunspot::Util::Coordinates.new(lat, lon) }

  # Remove these after we are totally on Solr 7
  string :citykeyword
  string :school_type
  string :school_database_state
  integer :overall_gs_rating
  string :school_grade_level
  integer :sorted_gs_rating_asc
  integer :school_id
  string :school_sortable_name
  float :distance
end

Sunspot.setup(City) do

end

Sunspot.setup(District) do

end

Sunspot::Adapters::DataAccessor.register(
  Search::SchoolSunspotDataAccessor,
  School
)

Sunspot::Adapters::InstanceAdapter.register(
  Search::SchoolSunspotInstanceAdapter,
  Search::SchoolDocument
)

Sunspot::Adapters::DataAccessor.register(
    Search::CitySunspotDataAccessor,
    City
)

Sunspot::Adapters::InstanceAdapter.register(
  Search::CitySunspotInstanceAdapter,
  Search::CityDocument
)

Sunspot::Adapters::DataAccessor.register(
    Sunspot::Adapters::DataAccessor,
    District
)

Sunspot::Adapters::InstanceAdapter.register(
    Search::DistrictSunspotInstanceAdapter,
    Search::DistrictDocument
)
