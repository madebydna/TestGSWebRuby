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

  end
end
