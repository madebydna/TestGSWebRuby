require_relative '../../feed_config/feed_constants'



module Feeds
  module TestRatingFeedTransformer
    include Feeds::FeedConstants

    def transpose_state_master_data_ratings_for_feed(state_master_data,state, rating_id)
        {
            :id => transpose_test_id(state,rating_id),
            :year => state_master_data['year'],
            :description => state_master_data['description']
        }
    end

    def transpose_data_for_xml(state,ratings_data = [],entity,entity_level)
      # Array.wrap will convert nil to [], Object to [Object], and leave existing arrays alone
      Array.wrap(ratings_data).try(:map) { |data| create_test_rating_hash_for_xml(state,data, entity, entity_level)}.compact
    end

    def create_test_rating_hash_for_xml(state,data,entity,entity_level)
      {:universal_id => transpose_universal_id(state,entity, entity_level),
                     # :entity_level => entity_level.titleize,
                     :test_rating_id => transpose_test_id(state,data['data_type_id']),
                     :rating => transpose_ratings(data,entity_level),
                     :url => transpose_url(entity,entity_level,state)
      }
    end

    def transpose_ratings(data,entity_level)
      if entity_level == ENTITY_TYPE_SCHOOL
        rating = data['school_value_text']|| data['school_value_float']
      elsif entity_level == ENTITY_TYPE_DISTRICT
        rating = data['value_text']|| data['value_float']
      end
      # Rating should be sent nil and not zero if data not present , that's why the try
      rating.try(:to_i)
    end

    def transpose_url(entity,entity_level,state)
      begin
        if entity_level == ENTITY_TYPE_DISTRICT
          city_district_url district_params_from_district(entity).merge(trailing_slash: true, protocol: 'https')
        elsif entity_level == ENTITY_TYPE_SCHOOL
          school_url entity, trailing_slash: true, protocol: 'https'
        end
      rescue  => e
         Feeds::FeedLog.log.info "Could not find the correct url for #{entity_level} in #{state} and id #{entity.id} hence state url will be sent"
         Feeds::FeedLog.log.error e
         state_url(state_params(state))
      end
    end
    def transpose_ratings_description(data_type_id,state)
      state_name= States.state_name(state).titleize
      # How we calculate test_description  can change based on decision from Product team
      if data_type_id == RATINGS_ID_RATING_FEED_MAPPING['official_overall']
        "The GreatSchools Rating helps parents compare schools within a state based on a variety of school quality indicators and provides a helpful picture of how effectively each school serves all of its students. Ratings are on a scale of 1 (below average) to 10 (above average) and can include test scores, college readiness, academic progress, advanced courses, equity, discipline and attendance data. We also advise parents to visit schools, consider other information on school performance and programs, and consider family needs as part of the school selection process."
      elsif data_type_id == RATINGS_ID_RATING_FEED_MAPPING['test_rating']

        "GreatSchools compared the test results for each grade and subject across all #{state_name} schools and divided them into 1 through 10 ratings (10 is the best).\
Please note, private schools are not required to release test results, so ratings are available \
only for public schools. GreatSchools Ratings cannot be compared across states,\
because of differences in the states' standardized testing programs.\
Keep in mind that when comparing schools using GreatSchools Ratings it's important to factor in \
other information, including the quality of each school's teachers, the school culture, special programs, etc."

      end
    end

  end
end
