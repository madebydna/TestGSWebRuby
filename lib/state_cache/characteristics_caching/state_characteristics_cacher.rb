class StateCharacteristicsCacher < StateCacher
  include StateCacheValidation

  CACHE_KEY = 'state_characteristics'
  STATE_CHARACTERISTICS_CENSUS_DATA_TYPES = [1, 2, 3, 4, 5, 6, 8, 9, 12, 13, 17, 23, 26, 28, 30, 33, 41, 42,
    102, 103, 123, 124, 129, 131, 133, 179, 296, 298, 319, 325, 417, 419]
  # 1 - Percentage of teachers in their first year
  # 2 - Bachelor's degree
  # 3 - Master's degree
  # 4 - Doctorate's degree
  # 5 - Student teacher ratio
  # 6 - Students participating in free or reduced-price lunch program  
  # 8 - English Learners
  # 9 - Ethnicity
  # 12 - Average years of teacher experience
  # 13 - Economically disadvantaged
  # 17 - Enrollment
  # 23 - Other degree
  # 26 - Master's degree or higher
  # 28 - Average years of teaching in district
  # 30 - Teaching experience 0-3 years
  # 33 - Percent classes taught by non-highly qualified teachers
  # 41 - Head official name
  # 42 - Head official email
  # 102 - ACT participation 
  # 103 - at least 5 years teaching experience
  # 123 - Female
  # 124 - Male
  # 129 - Teachers with no valid license
  # 131 - Percent classes taught by highly qualified teachers
  # 133 - Teachers with valid license
  # 179 - Percent Needing Remediation for College
  # 296 - SAT percent college ready 
  # 298 - 4-year high school graduation rate 
  # 319 - Average ACT score
  # 325 - ACT percent college ready
  # 417 - Percent of Students Passing AP/IB Exams 
  # 419 - Percent of students who meet UC/CSU entrance requirements 

  def self.listens_to?(data_type)
    :state_characteristics == data_type
  end
  
  def initialize(state)
    @state = state
  end

  def self.active?
    # ENV_GLOBAL['is_feed_builder'].present? && [true, 'true'].include?(ENV_GLOBAL['is_feed_builder'])
    true
  end

  def census_query
    CensusDataSetQuery.new(state)
        .with_data_types(STATE_CHARACTERISTICS_CENSUS_DATA_TYPES)
        .with_state_values
        .with_census_descriptions('Public')
  end

  def census_query_results #census only
    @_census_query_results ||= (
    census_data = CensusDataStateResults.new(census_query.to_a).filter_to_max_year_per_data_type!
    census_data.map do |obj|
      CharacteristicsCaching::QueryResultDecorator.new(@state&.upcase, obj)
    end.compact
    )
  end

  def build_hash_for_data_set(result)
    return nil unless result.state_average
    data_attributes.each_with_object({}) do |key, hash|
      value = result.try(key)
      if value
        key == :state_average ? hash[:state_value] = value : hash[key] = value
        if key == :breakdown
          if (config = result.data_set_with_values.try(:census_data_config_entry))
            hash[key] = config.label
          end
          hash[:original_breakdown] = value
        end
      end
      hash
    end
  end

  def data_attributes
    [
        :breakdown,
        :created,
        :grade,
        :state_average,
        :source,
        :year,
        :subject
    ]
  end

  def build_hash_for_cache
    cache_hash = census_query_results.each_with_object({}) do |result, hash|
      hash[result.label] ||= []
      hash_for_cache = build_hash_for_data_set(result)
      hash[result.label] << hash_for_cache if hash_for_cache.present?
    end
    validate!(cache_hash)
  end

end