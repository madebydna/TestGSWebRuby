module Feeds
  class TestRatingFeedDataReader
    def initialize(attributes = {})
      @school = attributes[:school]
      @district = attributes[:district ]
      @state = attributes[:state]
      @ratings_id_for_feed = attributes[:ratings_id_for_feed]
    end


    def get_school_data
      data = @school.try(:school_cache).cache_data['ratings']
      get_rating_data_for_feed(data)
    end

    def get_district_data
      data = @district.try(:district_cache).cache_data['ratings']
      get_rating_data_for_feed(data)
    end

    def get_master_data
      query_results =TestDataSet.ratings_config_for_state(@state,@ratings_id_for_feed)
    end

    private

    def get_rating_data_for_feed(ratings_cache_data)
      data = []
      data.push(ratings_cache_data.try(:find) { |h| h["data_type_id"]== @ratings_id_for_feed })
    end

  end
end