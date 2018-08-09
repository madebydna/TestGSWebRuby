# frozen_string_literal: true

module Feeds
  module OldTestGsdata
    class SubgroupsXmlWriter < Feeds::OldTestGsdata::XmlWriter
      def initialize(data_reader, output_path)
        super
        @root_element = 'gs-test-subgroup-feed'
        @schema = 'http://www.greatschools.org/feeds/greatschools-test-subgroup.xsd'
      end

      def write_test_result(uid, test_id, hash)
        super
        xml_builder.tag!('breakdown-id', hash['breakdown-id'])
        xml_builder.tag!('breakdown-name', hash['breakdowns'])
      end
    end
  end
end
