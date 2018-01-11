module Feeds
  module TestRatingFeedDataReader

    def get_school_data_for_ratings(school,ratings_id)
      data = school.try(:school_cache).cache_data['ratings']
      state = school['state'].downcase if school.present? && school['state'].present?
      get_rating_data_for_school_feed(data, state) if data.present?
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

    def get_rating_data_for_school_feed(ratings_cache_data, state)
      hash = {'data_type_id'=>174, 'year'=>0, 'school_value_text'=>nil, 'school_value_float'=>nil, 'test_data_type_display_name'=>'GreatSchools rating'}
      summary = ratings_cache_data['Summary Rating']
      if summary.present?
        hash['school_value_float'] = summary.first['school_value'].to_f
        hash['year'] = date_to_year(summary.first['source_date_valid'])
      elsif test_score_rating_used? state
        test_score_rating = ratings_cache_data['Test Score Rating']
        overall_test_score = test_score_rating.reject { |a| a.has_key? 'breakdowns' } if test_score_rating.present?
        hash['school_value_float'] = overall_test_score.first['school_value'].to_f if overall_test_score.present?
        hash['year'] = date_to_year(overall_test_score.first['source_date_valid']) if overall_test_score.present?
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