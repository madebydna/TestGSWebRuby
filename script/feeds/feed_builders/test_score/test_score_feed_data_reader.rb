require_relative '../../feed_config/feed_constants'


module Feeds
  module TestScoreFeedDataReader

    include Feeds::FeedConstants

    def get_school_test_score_data(school)
      school.try(:school_cache).cache_data['feed_test_scores']
    end

    def get_district_test_score_data(district)
      district.try(:district_cache).cache_data['feed_test_scores']
    end
    def get_test_score_state_master_data(state)
      state_test_infos = []
      TestDescription.where(state: state).find_each do |test|
        data_type_id = test.data_type_id
        test_info = TestDataType.where(:id => data_type_id).first
        test_data_set_info = TestDataSet.on_db(state.downcase.to_sym).
            where(:data_type_id => data_type_id).where(:active => 1).where(
            'display_target LIKE ?','%feed%').max_by(&:year)
        if test_data_set_info.present?
          state_test_info = {:id => state.upcase + data_type_id.to_s.rjust(5, '0'),
                             :test_name => test_info['description'],
                             :test_abbrv => test_info['name'],
                             :scale => test['scale'],
                             :most_recent_year => test_data_set_info['year'],
                             :level_code => test_data_set_info['level_code'],
                             :description => test['description']
          }
          state_test_infos.push(state_test_info)
        end
      end
      state_test_infos
    end

    def get_state_test_score_data(state,data_type)
      if data_type == WITH_NO_BREAKDOWN
        get_state_data_with_no_subgroup(state)
      elsif data_type == WITH_ALL_BREAKDOWN
        get_state_data_with_subgroup(state)
      end
    end

    private

        def get_state_data_with_no_subgroup(state)
          TestDataSet.test_scores_for_state(state)
        end

        def get_state_data_with_subgroup(state)
          TestDataSet.test_scores_subgroup_for_state(state)
        end
  end
end