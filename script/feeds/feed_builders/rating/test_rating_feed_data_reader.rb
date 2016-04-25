module FeedBuilders
  class TestRatingFeedDataReader
    def initialize(attributes = {})
      @school = attributes[:school]
      @district = attributes[:district ]
      @state = attributes[:state]
      @ratings_id_for_feed = attributes[:ratings_id_for_feed]
    end


    def get_school_ratings_cache_data
      @school.try(:school_cache).cache_data['ratings']
    end

    def get_district_ratings_cache_data
      @district.try(:district_cache).cache_data['ratings']
    end

    def get_master_data
      query_results =TestDataSet.ratings_config_for_state(@state,@ratings_id_for_feed)
    end



  end
end