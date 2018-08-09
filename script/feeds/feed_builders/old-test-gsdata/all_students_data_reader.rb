# frozen_string_literal: true

module Feeds
  module OldTestGsdata
    class AllStudentsDataReader < Feeds::OldTestGsdata::DataReader
      def cache_filter
        ->(h) { h['breakdowns'] == 'All Students' }
      end
    end
  end
end
