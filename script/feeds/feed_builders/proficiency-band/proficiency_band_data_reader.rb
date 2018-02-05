# frozen_string_literal: true

module Feeds
  module ProficiencyBand
    class ProficiencyBandDataReader
      include Feeds::FeedConstants

      attr_reader :state

      def initialize(state)
        @state = state
      end

      def each_result(&block)
        results.each(&block)
      end

      def results
        proficiency_bands
      end

      def proficiency_bands
        ActiveRecord::Base.connection.exec_query('select id, name, group_id as \'group-id\' from TestProficiencyBand order by id')
      end

    end
  end
end
