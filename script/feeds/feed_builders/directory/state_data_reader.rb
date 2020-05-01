# frozen_string_literal: true

require_relative './metrics_caching/metrics_builder'

module Feeds
  module Directory
    class StateDataReader
      include Feeds::FeedConstants
      include Feeds::FeedHelper

      CACHE_KEY_GSDATA = 'gsdata'
      CACHE_KEY_METRICS = 'metrics'

      attr_reader :state

      def initialize(state)
        @state = state.upcase
      end

      def universal_id
        @_universal_id ||= transpose_universal_id(@state, nil, 'state').to_i.to_s
      end

      def state_name
        @_state_name ||= States.labels_hash[@state.downcase]
      end

      def metrics_info
        @_metrics_info ||= begin
          data_builder = MetricsBuilder.new(state_cache, universal_id, 'state')
          data_builder.data_hashes
        end
      end

      def data_values
        @_data_values ||= begin
          state_attributes_hash = DIRECTORY_STATE_ATTRIBUTES.each_with_object({"entity" => "state"}) do |attribute, hash|
            hash[attribute.gsub('_','-')] = send(attribute.to_sym)
          end

          state_attributes_hash.merge(metrics_info)
        end
      end

      def state_cache
        @_state_cache ||= begin
          state_metrics_cache.merge(state_gsdata_cache)
        end
      end

      def state_metrics_cache
        @_state_metrics_cache ||= StateCache.for_state(CACHE_KEY_METRICS, @state)&.cache_data || {}
      end

      def state_gsdata_cache
        @_state_gsdata_cache ||= StateCache.for_state(CACHE_KEY_GSDATA, @state)&.cache_data || {}
      end
    end
  end
end