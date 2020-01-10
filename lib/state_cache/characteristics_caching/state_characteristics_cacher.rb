class StateCharacteristicsCacher < StateCacher
  include StateCacheValidation

  CACHE_KEY = 'state_characteristics'
  STATE_CHARACTERISTICS_CENSUS_DATA_TYPES = [1, 2, 3, 4, 5, 6, 8, 9, 12, 13, 17, 23, 26, 28, 30, 33, 41, 42, 102, 103, 123, 124,
                                             129, 131, 133, 179, 296, 298, 319, 325, 417, 419, 443, 444, 445, 446, 447, 448, 449,
                                             450, 451, 452, 453, 454, 455, 456, 457, 458, 459, 460, 461]
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
  # 443 - Percent enrolled in any public in-state postsecondary institution within 12 months after graduation
  # 444 - Percent enrolled in any postsecondary institution within 12 months after graduation
  # 447 - Percent enrolled in any 2 year postsecondary institution within 6 months after graduation
  # 448 - Percent enrolled in any 2 year postsecondary institution within the immediate fall after graduation
  # 449 - Percent enrolled in any 2 year public in-state postsecondary institution within the immediate fall after graduation
  # 450 - Percent enrolled in any 4 year postsecondary institution within 6 months after graduation
  # 451 - Percent enrolled in any 4 year postsecondary institution within the immediate fall after graduation
  # 452 - Percent enrolled in any 4 year public in-state postsecondary institution within the immediate fall after graduation
  # 453 - Percent enrolled in any in-state postsecondary institution within 12 months after graduation
  # 454 - Percent enrolled in any in-state postsecondary institution within the immediate fall after graduation
  # 455 - Percent enrolled in any out-of-state postsecondary institution within the immediate fall after graduation
  # 456 - Percent enrolled in any postsecondary institution within 24 months after graduation
  # 457 - Percent enrolled in any postsecondary institution within 6 months after graduation
  # 458 - Percent enrolled in any public in-state postsecondary institution or intended to enroll in any out-of-state institution, or in-state private institution within 18 months after graduation
  # 459 - Percent enrolled in any public in-state postsecondary institution within the immediate fall after graduation
  # 460 - Percent Enrolled in a public 4 year college and Returned for a Second Year
  # 461 - Percent Enrolled in a public 2 year college and Returned for a Second Year

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