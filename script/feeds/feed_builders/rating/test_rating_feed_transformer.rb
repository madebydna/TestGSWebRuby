require_relative 'test_rating_feed_data_reader'
require_relative '../../feed_config/feed_constants'



module Feeds
  module TestRatingFeedTransformer
    include Feeds::FeedConstants

    def transpose_state_master_data_ratings_for_feed(state_master_data,state)
      state_master_data_for_xml = state_master_data.try(:map) do |data|
        {
            :id => transpose_test_id(data[:data_type_id]),
            :year => data[:year],
            :description => transpose_ratings_description(data[:data_type_id],state)
        }
      end
    end

    def transpose_data_for_xml(ratings_data = [],entity,entity_level)
      # Array.wrap will convert nil to [], Object to [Object], and leave existing arrays alone
      Array.wrap(ratings_data).try(:map) { |data| create_test_rating_hash_for_xml(data, entity, entity_level)}.compact

    end

    def create_test_rating_hash_for_xml(data,entity,entity_level)
      test_rating = {:universal_id => transpose_universal_id(entity, entity_level),
                     :entity_level => entity_level.titleize,
                     :test_rating_id => transpose_test_id(data["data_type_id"]),
                     :rating => transpose_ratings(data,entity_level),
                     :url => transpose_url(entity,entity_level)
      }
    end

    def transpose_ratings(data,entity_level)
      if (entity_level == ENTITY_TYPE_SCHOOL)
        rating = data["school_value_text"]|| data["school_value_float"]
      elsif (entity_level == ENTITY_TYPE_DISTRICT)
        rating = data["value_text"]|| data["value_float"]
      end
      # Rating should be sent nil and not zero if data not present , that's why the try
      rating.try(:to_i)
    end

    def transpose_url(entity,entity_level)
      begin
        if (entity_level == ENTITY_TYPE_DISTRICT)
          url = city_district_url district_params_from_district(entity)
        elsif (entity_level == ENTITY_TYPE_SCHOOL)
          url = school_url entity
        end
      rescue  => e
        puts "#{e}"
        url = state_url(state_params(@state))
      end
    end

  end
end