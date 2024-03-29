# frozen_string_literal: true

class DistrictCharacteristicsCacher < DistrictCacher
  include DistrictCacheValidation

  CACHE_KEY = 'district_characteristics'
  DIRECTORY_CENSUS_DATA_TYPES = [9, 17, 76, 77, 78, 102, 178, 179, 182, 262, 273, 277, 296, 298, 319, 320, 321, 325, 417, 419]
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
  # 76 - Graduating seniors pursuing 4 year college/university
  # 77 - Graduating seniors pursuing 2 year college/university
  # 78 - Graduating seniors pursuing other college                                                                                                                                                      
  # 102 - ACT participation 
  # 103 - at least 5 years teaching experience
  # 129 - Teachers with no valid license
  # 131 - Percent classes taught by highly qualified teachers
  # 133 - Teachers with valid license
  # 178 - Percent Enrolled in College Immediately Following High School
  # 179 - Percent Needing Remediation for College
  # 182 - Percent Enrolled in College and Returned for a Second Year
  # 262 - Percent enrolled in any institution of higher learning in the last 0-16 months
  # 273 - Percent enrolled in a 2-year institution of higher learning in the last 0-16 months
  # 277 - Percent enrolled in a 4-year institution of higher learning in the last 0-16 months
  # 296 - SAT percent college ready  
  # 298 - 4-year high school graduation rate
  # 319 - Average ACT score
  # 320 - Percent of students who will attend out-of-state colleges
  # 321 - Percent of students who will attend in-state colleges
  # 325 - ACT percent college ready 
  # 417 - Percent of Students Passing AP/IB Exams 
  # 419 - Percent of students who meet UC/CSU entrance requirements 

  def self.listens_to?(data_type)
    data_type == :district_characteristics
  end

  def self.active?
    true
  end

  def census_query
    CensusDataSetQuery.new(district.state)
        .with_data_types(DIRECTORY_CENSUS_DATA_TYPES)
        .with_district_values(district.id)
        .with_census_descriptions('Public')
  end

  def census_query_results
    @_census_query_results ||= begin
      census_data = CensusDataDistrictResults.new(census_query.to_a).filter_to_max_year_per_data_type!
      census_data.map do |obj|
        CharacteristicsCaching::QueryResultDecorator.new(district.state, obj)
      end.compact
    end
  end

  def build_hash_for_data_set(result)
    return nil unless result.district_value
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
    %i(breakdown district_created grade district_value source year subject_id state_average subject)
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