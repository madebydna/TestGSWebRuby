class TestScoresCaching::DistrictTestScoresCacher < TestScoresCaching::DistrictBase

  CACHE_KEY = 'feed_test_scores'

  def query_results
    # @query_results ||= (
    #   results = TestDataSet.fetch_feed_test_scores_district(district).select do |result|
    #     data_type_id = result.data_type_id
    #     # skip this if no corresponding test data type
    #     test_data_types && test_data_types[data_type_id].present?
    #   end
    #   results.map { |obj| TestScoresCaching::DistrictQueryResultDecorator.new(district.state, obj) }
    # )
    @query_results ||=
      begin
        DataValue.find_by_district_and_data_type_tags(district.state, district.id, 'state_test')
          .with_configuration('feeds')
          .map {|obj| TestScoresCaching::DistrictQueryResultDecorator.new(district.state, obj)}
      end
  end

  def build_hash_for_cache
    hash = {}
    query_results.map do |data_set_and_value|
      hash.deep_merge!(build_hash_for_data_set(data_set_and_value))
    end
   hash
  end

  def self.active?
        ENV_GLOBAL['is_feed_builder'].present? && [true, 'true'].include?(ENV_GLOBAL['is_feed_builder'])
  end

  def innermost_hash(test)
    hash = {
        number_students_tested: test.number_students_tested,
        score: test.school_value,
        state_average: test.state_value
    }
    if test.proficiency_band_id.present?
      hash.merge!(band_id: test.proficiency_band_id)
    end

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
