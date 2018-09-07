module Feeds
  module TestRatingFeedDataReader

    def get_school_data_for_ratings(school,ratings_id)
      data = school.try(:school_cache).cache_data['ratings']
      state = school['state'].downcase if school.present? && school['state'].present?
      get_rating_data_for_school_feed(data, state, ratings_id) if data.present?
    end

    def get_district_data_for_ratings(district, ratings_id)
      data = district.try(:district_cache).cache_data['ratings']
      get_rating_data_for_district_feed(data,ratings_id)
    end

    def get_ratings_master_data(state, rating_id)
      TestDataSet.ratings_config_for_state(state,rating_id)
    end

    private

    def date_to_year(date)
      date.slice(0..3).to_i
    end

    def data_type_id_to_name
      {
          174 => 'Summary Rating',
          164 => 'Test Score Rating'
      }
    end

    def get_rating_data_for_school_feed(ratings_cache_data, state, ratings_id)
      hash = {'data_type_id'=>ratings_id, 'year'=>0, 'school_value_text'=>nil, 'school_value_float'=>nil, 'test_data_type_display_name'=>'GreatSchools rating'}
      rating_name = data_type_id_to_name[ratings_id]
      ratings_hashes = ratings_cache_data[rating_name]
      rating_data = nil
      if ratings_hashes
        all_values = RatingsCaching::Value.from_array_of_hashes(ratings_hashes)
        rating_data = all_values.having_school_value.for_all_students.expect_only_one(
            "Expecting only one #{rating_name}", state: state
        )
      end
      if rating_data.present?
        hash['school_value_float'] = rating_data.school_value_as_int
        hash['year'] = rating_data.source_year
      elsif ratings_id == 174 && test_score_rating_used?(state)
        hash['data_type_id'] = 164
        ratings_hashes = ratings_cache_data['Test Score Rating']
        value_objects = RatingsCaching::Value.from_array_of_hashes(ratings_hashes)
        overall_test_score = value_objects.having_school_value.for_all_students.expect_only_one(
          "Should only have found one Test Score Rating",
          state: state
        )
        hash['school_value_float'] = overall_test_score.school_value_as_int if overall_test_score.present?
        hash['year'] = overall_test_score.source_year if overall_test_score.present?
      end
      hash['school_value_float'].present? || hash['school_value_text'].present? ? hash : nil
    end

    def test_score_rating_used?(state)
      whitelist = %w(ak id me nd nh sd vt)
      whitelist.include? state
    end

    def get_rating_data_for_district_feed(ratings_cache_data,ratings_id_for_feed)
      Array.wrap(ratings_cache_data).try(:select) { |h| h['data_type_id']== ratings_id_for_feed }
      .try(:max_by) { |h| h['year'] }
    end

  end
end
