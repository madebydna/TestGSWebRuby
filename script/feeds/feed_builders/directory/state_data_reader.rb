# frozen_string_literal: true

require_relative './characteristics_caching/characteristics_builder'

module Feeds
  module Directory
    class StateDataReader
      include Feeds::FeedConstants
      include Feeds::FeedHelper

      CACHE_KEY_GSDATA = 'gsdata'
      CACHE_KEY_CHARACTERISTICS = 'state_characteristics'

      attr_reader :state

      def initialize(state)
        @state = state.upcase
      end

      def universal_id
        @_universal_id ||= transpose_universal_id(@state, nil, 'state').to_s
      end

      def state_name
        @_state_name ||= States.labels_hash[@state.downcase]
      end

      def census_info
        @_census_info ||= begin
          data_builder = CharacteristicsBuilder.new(state_cache, universal_id, 'state')
          data_builder.data_hashes
        end
      end

      def data_values
        @_data_values ||= begin
          state_attributes_hash = DIRECTORY_STATE_ATTRIBUTES.each_with_object({}) do |attribute, hash|
            hash[attribute.gsub('_','-')] = send(attribute.to_sym)
          end

          census_data_hash = census_info.each_with_object({}) do |data_object, data_hash|
            key = data_object.keys.first
            value = data_object.values.first
            data_hash[key] = value
          end

          state_attributes_hash.merge(census_data_hash)
        end
      end

      def state_cache
        @_state_cache ||= begin
          state_characteristics_cache.merge(state_gsdata_cache)
        end
      end

      def state_characteristics_cache
        @_state_characteristics_cache ||= StateCache.for_state(CACHE_KEY_CHARACTERISTICS, @state)&.cache_data || {}
      end

      def state_gsdata_cache
        @_state_gsdata_cache ||= StateCache.for_state(CACHE_KEY_GSDATA, @state)&.cache_data || {}
      end
    end
  end
end