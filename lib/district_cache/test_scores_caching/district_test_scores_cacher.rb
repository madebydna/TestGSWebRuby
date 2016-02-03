class TestScoresCaching::DistrictTestScoresCacher < TestScoresCaching::DistrictBase

  CACHE_KEY = 'test_scores'

  def query_results
    require 'pry'
    binding.pry
    @query_results ||= (
      results = TestDataSet.fetch_feed_test_scores_district(district).select do |result|
        data_type_id = result.data_type_id
        # skip this if no corresponding test data type
        test_data_types && test_data_types[data_type_id].present?
      end
      results.map { |obj| TestScoresCaching::DistrictQueryResultDecorator.new(district.state, obj) }
    )
  end

  def build_hash_for_cache
    hash = {}
    require 'pry'
    binding.pry
    query_results.map do |data_set_and_value|
      hash.deep_merge!(build_hash_for_data_set(data_set_and_value))
    end
    add_lowest_grade_to_hash(hash)
   hash
  end

  def add_lowest_grade_to_hash(data_type_hash)
    data_type_hash.each do |data_type_id, test_hash|
      lowest_grade = test_hash[:grades].keys.map(&:to_i).min
      test_hash[:lowest_grade] = lowest_grade
    end
  end

  def innermost_hash(test)
    hash = {
      number_students_tested: test.number_students_tested,
      score: test.school_value,
      state_average: test.state_value,
    }

    proficiency_band_name = test.proficiency_band_name
    if proficiency_band_name
      hash.transform_keys! do |key|
        "#{proficiency_band_name}_#{key}".to_sym
      end
    end
    hash
  end

  def build_hash_for_data_set(test)
    {
        test.data_type_id => {
            test.test_scores_breakdown_name => {
                test_label: test.test_label,
                test_source: test.test_source,
                test_description: test.test_description,
                grades: {
                    test.grade.to_s => {
                        label: test.grade_label,
                        level_code: {
                            test.level_code.to_s => {
                                test.subject => {
                                    test.year => innermost_hash(test)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
  end

end
