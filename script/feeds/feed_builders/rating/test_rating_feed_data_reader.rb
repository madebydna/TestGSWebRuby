module Feeds
  module TestRatingFeedDataReader

    def get_school_data_for_ratings(school,ratings_id)
      data = school.try(:school_cache).cache_data['ratings']
      get_rating_data_for_feed(data,ratings_id)
    end

    def get_district_data_for_ratings(district, ratings_id)
      data = district.try(:district_cache).cache_data['ratings']
      get_rating_data_for_feed(data,ratings_id)
    end

    def get_ratings_master_data(state, rating_id)
      TestDataSet.ratings_config_for_state(state,rating_id)
    end

    private

    def get_rating_data_for_feed(ratings_cache_data,ratings_id_for_feed)
      Array.wrap(ratings_cache_data).try(:select) { |h| h['data_type_id']== ratings_id_for_feed }
    end

  end
end