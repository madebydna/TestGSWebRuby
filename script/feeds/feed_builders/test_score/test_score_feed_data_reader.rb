module FeedBuilders
  class TestScoreFeedDataReader
    def initialize(attributes = {})
      @school = attributes[:school]
      @district = attributes[:district ]
      @state = attributes[:state]
    end

    def get_school_data
      @school.try(:school_cache).cache_data['feed_test_scores']
    end

    def get_district_data
      @district.try(:district_cache).cache_data['feed_test_scores']
    end
    def get_master_data
      state_test_infos = []
      state = @state
      TestDescription.where(state: state).find_each do |test|
        data_type_id = test.data_type_id
        test_info = TestDataType.where(:id => data_type_id).first
        test_data_set_info = TestDataSet.on_db(state.downcase.to_sym).
            where(:data_type_id => data_type_id).where(:active => 1).where(:display_target => 'feed').max_by(&:year)
        if test_data_set_info.present?
          state_test_info = {:id => state.upcase + data_type_id.to_s.rjust(5, '0'),
                             :test_id => data_type_id,
                             :test_name => test_info["description"],
                             :test_abbrv => test_info["name"],
                             :scale => test["scale"],
                             :most_recent_year => test_data_set_info["year"],
                             :level_code => test_data_set_info["level_code"],
                             :description => test["description"]
          }
          state_test_infos.push(state_test_info)
        end
      end
      state_test_infos
    end

    def get_state_data
      TestDataSet.test_scores_for_state(@state)
    end
  end
end