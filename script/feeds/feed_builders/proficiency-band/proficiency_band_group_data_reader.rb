# frozen_string_literal: true

module Feeds
  module ProficiencyBand
    class ProficiencyBandGroupDataReader
      include Feeds::FeedConstants

      attr_reader :state

      def initialize(state)
        @state = state
      end

      def each_result(&block)
        results.each(&block)
      end

      def results
        proficiency_band_groups
      end

      def proficiency_band_groups
        ActiveRecord::Base.connection.exec_query('select id, description from TestProficiencyBandGroup order by id')
      end

    end
  end
end
