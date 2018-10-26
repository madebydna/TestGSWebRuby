# frozen_string_literal: true

module Feeds
  module NewTestGsdata
    class SubgroupsCsvWriter < Feeds::NewTestGsdata::CsvWriter
      def initialize(data_reader, output_path)
        super
        @do_description_file = false
      end

      def write_test_result(test_abbr, universal_id, h)
        arr = super
        arr << h['breakdowns'] ? h['breakdowns'] : ''
        arr
      end

      def get_column_titles
        super.clone << 'breakdowns'
      end
    end
  end
end

