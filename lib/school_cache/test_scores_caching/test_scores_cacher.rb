class TestScoresCaching::TestScoresCacher < TestScoresCaching::Base

  CACHE_KEY = 'test_scores'

  def build_hash_for_cache
    hash = {}
    query_results.map do |data_set_and_value|
      hash.deep_merge!(build_hash_for_data_set(data_set_and_value)) # impl in subclass
    end

    add_lowest_grade_to_hash(hash)

    hash
  end

  def inject_grade_all(data_sets_and_values)
    TestScoresCaching::GradeAllCalculator.new(data_sets_and_values).inject_grade_all
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
        state_number_tested: test.state_number_tested,
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
end
