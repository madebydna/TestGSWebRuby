class FeedCharacteristicsCaching::FeedCharacteristicsCacher < Cacher
  include CacheValidation

  CACHE_KEY = 'feed_characteristics'
  DIRECTORY_FIELDS = %w(city county district_id DISTRICT_NAME fax FIPScounty id (district doesn't have id) lat level level_code
                        lon name nces_code phone SCHOOL SUMMARY state_id state street subtype type UNIVERSAL_ID UNIVERSAL_DISTRICT_ID
                        URL (has 'types' - pointing to tabs... just point to profile page?) home_page_url zipcode)
  DIRECTORY_CENSUS_DATA_TYPES = [1, 2, 3, 4, 5, 6, 8, 9, 12, 13, 17, 23, 26, 28, 30, 33, 41, 42, 103, 129, 131, 133]
  # 1 - Percentage of teachers in their first year
  # 2 - Bachelor's degree
  # 3 - Master's degree
  # 4 - Doctorate's degree
  # 5 - Student teacher ratio
  # 6 - FRL
  # 8 - ELL
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
  # 103 - at least 5 years teaching experience
  # 129 - Teachers with no valid license
  # 131 - Percent classes taught by highly qualified teachers
  # 133 - Teachers with valid license


  def self.listens_to?(data_type)
    :feed_characteristics == data_type
  end

  def census_query
    CensusDataSetQuery.new(school.state)
      .with_data_types(DIRECTORY_CENSUS_DATA_TYPES)
      .with_school_values(school.id)
      .with_census_descriptions(school.type)
  end

  def census_query_results #census only
    @_census_query_results ||= (
      census_data = CensusDataResults.new(census_query.to_a).filter_to_max_year_per_data_type!
      census_data.map do |obj|
        CharacteristicsCaching::QueryResultDecorator.new(school.state, obj)
      end.compact
    )
  end

  def build_hash_for_data_set(result)
    return nil unless result.school_value
    data_attributes.each_with_object({}) do |key, hash|
      value = result.try(key)
      if value
        hash[key] = value
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
        :school_value,
        :source,
        :year
    ]
  end

  def build_hash_for_cache
    cache_hash = census_query_results.each_with_object({}) do |result, hash|
      hash[result.label] ||= []
      hash[result.label] << build_hash_for_data_set(result)
    end
    validate!(cache_hash)
    cache_hash.merge!(school_object_hash)
  end

  def school_directory_keys
    %w(county district_id city fax FIPScounty id lat level level_code lon name nces_code phone state state_id street subtype type home_page_url zipcode)
  end

  def school_object_hash
    school_directory_keys.each_with_object({}) do |key, hash|
      hash[key] = [{ school_value: school.send(key) }] # the array wrap is for consistency
    end
  end

  def self.active?
    ENV_GLOBAL['is_feed_builder'].present? && [true, 'true'].include?(ENV_GLOBAL['is_feed_builder'])
  end

end
