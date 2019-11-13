module Feeds
  module TestRatingFeedDataReader

    def get_school_data_for_ratings(school,ratings_type)
      data = school.try(:school_cache).cache_data['ratings']
      state = school['state'].downcase if school.present? && school['state'].present?
      get_rating_data_for_school_feed(data, state, ratings_type) if data.present?
    end

    def get_district_data_for_ratings(district, ratings_id)
      data = district.try(:district_cache).cache_data['ratings']
      get_rating_data_for_district_feed(data,ratings_id)
    end

    def get_ratings_master_data(state)
      state_info = StateCache.for_state('feed_ratings', state)
      JSON.parse(state_info.value)
    end

    private

    def date_to_year(date)
      date.slice(0..3).to_i
    end

    def name_to_data_type_id
      {
          'Summary Rating' => 174,
          'Test Score Rating' => 164
      }
    end

    def get_rating_data_for_school_feed(ratings_cache_data, state, ratings_type)
      hash = {'data_type_id'=>name_to_data_type_id[ratings_type], 'year'=>0, 'school_value_float'=>nil, 'test_data_type_display_name'=>'GreatSchools rating'}
      ratings_hashes = ratings_cache_data[ratings_type]
      # rating_data = nil
      if ratings_hashes
        all_values = RatingsCaching::Value.from_array_of_hashes(ratings_hashes)
        rating_data = all_values.having_school_value.for_all_students.expect_only_one(
            "Expecting only one #{ratings_type}", state: state
        )
      end
      hash['school_value_float'] = rating_data&.school_value_as_int
      hash['year'] = rating_data&.source_year
      hash['school_value_float'].present? ? hash : nil
    end

    def get_rating_data_for_district_feed(ratings_cache_data,ratings_id_for_feed)
      Array.wrap(ratings_cache_data).try(:select) { |h| h['data_type_id']== ratings_id_for_feed }
      .try(:max_by) { |h| h['year'] }
    end

  end
end
