# frozen_string_literal: true

module Feeds
  module NewTestGsdata
    class SubgroupsXmlWriter < Feeds::NewTestGsdata::XmlWriter
      def initialize(data_reader, output_path)
        super
        @root_element = 'gs-test-subgroup-feed'
        @schema = 'http://www.greatschools.org/feeds/gs-test-subgroups.xsd'
      end

      def write_test_result(h)
        super
        within_tag('breakdowns') do
          xml_builder.tag!('breakdown-name', h['breakdowns'])
        end
      end
    end
  end
end

