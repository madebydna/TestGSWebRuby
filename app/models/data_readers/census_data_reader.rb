# encoding: utf-8

#
# Retrieves CensusData and builds hashes in various formats
#
class CensusDataReader
  attr_accessor :school

  SCHOOL_CACHE_KEYS = ['characteristics']

  def initialize(school)
    @school = school
  end

  def school_cache_keys
    SCHOOL_CACHE_KEYS
  end

  def all_raw_data(specified_data_types=nil)
    raise 'Data types must be specified' unless specified_data_types.present?
    results = raw_data(specified_data_types)
    results
  end

  def census_data_by_data_type_query(specified_data_types)
    CensusDataSetQuery.new(school.state)
      .with_data_types(specified_data_types)
      .with_school_values(school.id)
      .with_district_values(school.district_id)
      .with_state_values
      .with_census_descriptions(school.type)
  end

  def raw_data(specified_data_types=nil)
    @all_census_data ||= nil
    return @all_census_data if @all_census_data

    # Get data for all data types
    results = census_data_by_data_type_query(specified_data_types).to_a

    @all_census_data =
      CensusDataResults.new(results)
        .filter_to_max_year_per_data_type!
        .sort_school_value_desc_by_date_type!
  end
end
