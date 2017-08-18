module Feeds
  class StateFeed
    include Feeds::FeedConstants

    attr_reader :state, :data_type

    def initialize(state, data_type)
      @state = state
      @data_type = data_type
      @data_builder_class = StateTestDataReader
    end

    def new_data_builder(*args)
      @data_builder_class.new(*args)
    end

    def each_result
      data_sets = new_data_builder(state, data_type).decorated_data_sets
      hashes = data_sets.map { |tds| format(tds) }
      yield(hashes)
    end

    def format(test_data_set)
      test_data_hash = {
        universal_id: TestCalculations.calculate_universal_id(state),
        test_id: test_data_set.test_id,
        year: test_data_set.year,
        subject_name: test_data_set.subject,
        grade_name: test_data_set.grade,
        level_code_name: test_data_set.level_code,
        score: test_data_set.test_score,
        proficiency_band_id: test_data_set.proficiency_band_id,
        proficiency_band_name: test_data_set.proficiency_band_name,
        number_tested: test_data_set.number_tested
      }
      if data_type == WITH_ALL_BREAKDOWN
        test_data_hash.merge!({
                                breakdown_id: test_data_set.breakdown_id,
                                breakdown_name: test_data_set.breakdown_name
                              })
      end

      test_data_hash
    end
  end
end