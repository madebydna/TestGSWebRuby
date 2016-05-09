require_relative '../../feed_config/feed_constants'



module Feeds
  module TestRatingFeedTransformer
    include Feeds::FeedConstants

    def transpose_state_master_data_ratings_for_feed(state_master_data,state)
      state_master_data.try(:map) do |data|
        {
            :id => transpose_test_id(state,data[:data_type_id]),
            :year => data[:year],
            :description => transpose_ratings_description(data[:data_type_id],state)
        }
      end
    end

    def transpose_data_for_xml(state,ratings_data = [],entity,entity_level)
      # Array.wrap will convert nil to [], Object to [Object], and leave existing arrays alone
      Array.wrap(ratings_data).try(:map) { |data| create_test_rating_hash_for_xml(state,data, entity, entity_level)}.compact
    end

    def create_test_rating_hash_for_xml(state,data,entity,entity_level)
      {:universal_id => transpose_universal_id(state,entity, entity_level),
                     :entity_level => entity_level.titleize,
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
          city_district_url district_params_from_district(entity)
        elsif entity_level == ENTITY_TYPE_SCHOOL
          school_url entity
        end
      rescue  => e
        puts "#{e}"
         state_url(state_params(state))
      end
    end
    def transpose_ratings_description(data_type_id,state)
      state_name= States.state_name(state).titleize
      # How we calculate test_description  can change based on decision from Product team
      if data_type_id == RATINGS_ID_RATING_FEED_MAPPING['official_overall']
        "The GreatSchools rating is a simple tool for parents to compare schools based on test scores,\
student academic growth, and college readiness. It compares schools across the state, \
where the highest rated schools in the state are designated as 'Above Average' and the lowest 'Below Average'.\
It is designed to be a starting point to help parents make baseline comparisons. We always advise parents to visit \
the school and consider other information on school performance and programs, as well as consider their child's and \
family's needs as part of the school selection process."

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