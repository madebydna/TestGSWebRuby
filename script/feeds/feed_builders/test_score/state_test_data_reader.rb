module Feeds
  class StateTestDataReader
    include Feeds::FeedConstants

    attr_reader :state, :data_type

    def initialize(state, data_type)
      @state = state
      @data_type = data_type
    end

    def each
      data_sets = test_data_sets.map do |data_set|
        TestDataSetDecorator.new(state, data_set)
      end
      yield(data_sets)
    end

    private

    def test_data_sets
      @_test_data_sets ||= (
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

  end
end