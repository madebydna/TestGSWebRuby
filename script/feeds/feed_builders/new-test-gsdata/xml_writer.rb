# frozen_string_literal: true

module Feeds
  module NewTestGsdata
    class XmlWriter
      include Feeds::FeedConstants
      include Feeds::FeedHelper

      def initialize(data_reader, output_path)
        @root_element = 'gs-test-feed'
        @schema = 'http://www.greatschools.org/feeds/gs-test.xsd'
        @feed_file_path = output_path
        @data_reader = data_reader
      end

      def write_feed
        within_root_node do
          write_test_info
        end
        close_file
      end

      private

      def write_test_info
        @data_reader.each_state_test do |hash|
          within_tag('test') do
            test_name = hash['test-name']
            xml_builder.tag!('test-name', test_name)
            xml_builder.tag!('test-abbrv', hash['test-abbrv'])
            xml_builder.tag!('scale', hash['scale'])
            xml_builder.tag!('most-recent-year', hash['most-recent-year'])
            xml_builder.tag!('description', hash['description'])
            xml_builder.tag!('state-abbrv', @data_reader.state&.upcase)
            write_state_info(test_name)
            write_district_info(test_name)
            write_school_info(test_name)
          end
        end
      end

      def write_state_info(test_name)
        within_tag('state') do
          @data_reader.each_state_result_for_test_name(test_name) do |hash|
            write_entity_info(hash, state_uid)
          end
        end
      end

      def write_district_info(test_name)
        if @data_reader.district_data_for_test_name? test_name
          within_tag('district') do
            @data_reader.each_district_result_for_test_name(test_name) do |hash, district_id|
              write_entity_info(hash, district_uid(district_id))
            end
          end
        end
      end

      def write_school_info(test_name)
        if @data_reader.school_data_for_test_name? test_name
          within_tag('school') do
            @data_reader.each_school_result_for_test_name(test_name) do |hash, school_id|
              write_entity_info(hash, school_uid(school_id))
            end
          end
        end
      end

      def write_entity_info(hash, universal_id)
        if hash.present?
          within_tag('entity') do
            xml_builder.tag!('universal-id', universal_id)
            within_tag('results') do
              write_test_results(hash)
            end
          end
        end
      end

      def write_test_results(hash)
        hash.each do |h|
          within_tag('test-result') do
            write_test_result(h)
          end
        end
      end

      def write_test_result(h)
        xml_builder.tag!('year', h['year'])
        xml_builder.tag!('subject-name', h['subject-name'])
        xml_builder.tag!('grade', h['grade'])
        xml_builder.tag!('score', h['score'])
        xml_builder.tag!('proficiency-band-name', h['proficiency-band-name'])
        xml_builder.tag!('number-tested', h['number-tested']) unless h['number-tested'].nil?
      end

      def file
        @_file ||= File.open(@feed_file_path, 'w')
      end

      def xml_builder
        @_xml_builder ||= begin
          xml = Builder::XmlMarkup.new(:target => file, :indent => 1)
          xml.instruct! :xml, :version => '1.0', :encoding => 'UTF-8'
          xml
        end
      end

      def within_root_node
        xml_builder.tag!(
            @root_element,
            'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
            :'xsi:noNamespaceSchemaLocation' => @schema
        ) do
          yield(xml_builder)
        end
      end

      def close_file
        file.close
      end

      def within_tag(tag_name)
        xml_builder.tag! tag_name do
          yield(xml_builder)
        end
      end

      def write_xml_tag(data, tag_name)
        if data.present?
          xml_builder.tag! tag_name do
            data.each do |key, value|
              if value.is_a?(Array)
                value.each { |hash| write_xml_tag(hash, key) }
              else
                xml_builder.tag! key, value
              end
            end
          end
        end
      end

      def school_uid(id)
        transpose_universal_id(@data_reader.state, Struct.new(:id).new(id), ENTITY_TYPE_SCHOOL)
      end

      def district_uid(id)
        transpose_universal_id(@data_reader.state, Struct.new(:id).new(id), ENTITY_TYPE_DISTRICT)
      end

      def state_uid
        transpose_universal_id(@data_reader.state, nil, nil)
      end

      def test_id(id)
        "#{@data_reader.state.upcase}#{id.to_s.rjust(5, '0')}"
      end
    end
  end
end
