class TestScoresCaching::BreakdownsCacher < TestScoresCaching::TestScoresCacher

  CACHE_KEY = 'test_scores'

  def query_results
    @query_results ||= (
      results =
        (
          TestDataSet.fetch_test_scores(school, 1, breakdown_id: 1) +
          TestDataSet.fetch_test_scores(school, 1, grade: 'All')
        ).select do |result|
          data_type_id = result.data_type_id
          # skip this if no corresponding test data type
          test_data_types && test_data_types[data_type_id].present?
        end
        results.map { |obj| TestScoresCaching::QueryResultDecorator.new(school.state, obj) }
    )
  end

  def add_lowest_grade_to_hash(data_type_hash)
    data_type_hash.each do |data_type_id, test_hash|
      test_hash.each do |breakdown, breakdown_hash|
        lowest_grade = breakdown_hash[:grades].keys.map(&:to_i).min
        breakdown_hash[:lowest_grade] = lowest_grade
      end
    end
  end

  def build_hash_for_data_set(test)
    {
      test.data_type_id => {
        test.breakdown_name => {
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