module Feeds
  class StateDataBuilder
    include Feeds::FeedConstants

    attr_reader :state, :data_type

    def initialize(state, data_type)
      @state = state
      @data_type = data_type
    end

    def to_hash
      transpose_state_data_for_feed(test_score_data)
    end

    private

    def test_score_data
      @_test_score_data ||= (
      if data_type == WITH_NO_BREAKDOWN
        get_state_data_with_no_subgroup
      elsif data_type == WITH_ALL_BREAKDOWN
        get_state_data_with_subgroup
      end
      )
    end

    def get_state_data_with_no_subgroup
      TestDataSet.test_scores_for_state(state)
    end

    def get_state_data_with_subgroup
      TestDataSet.test_scores_subgroup_for_state(state)
    end

    def transpose_state_data_for_feed(test_data_sets)
      test_data_sets.map do |test_data_set|
        test_data_set = TestDataSetDecorator.new(state, test_data_set)
        entity_level = ENTITY_TYPE_STATE
        entity = nil

        test_data_hash = {
          universal_id: test_data_set.universal_id(entity, entity_level),
          test_id: test_data_set.test_id,
          year: test_data_set.year,
          subject_name: test_data_set.subject_name,
          grade_name: test_data_set.grade_name,
          level_code_name: test_data_set.level_code,
          score: test_data_set.test_score(entity_level),
          proficiency_band_id: test_data_set.proficiency_band_id(entity_level),
          proficiency_band_name: test_data_set.proficiency_band_name,
          number_tested: test_data_set.number_tested(entity_level)
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
end