# frozen_string_literal: true

module Feeds
  module NewTestGsdata
    class AllStudentsDataReader < Feeds::NewTestGsdata::DataReader
      def cache_filter
        ->(h) { h['breakdowns'] == 'All Students' }
      end
    end
  end
end
