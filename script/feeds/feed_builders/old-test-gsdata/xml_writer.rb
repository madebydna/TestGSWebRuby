# frozen_string_literal: true

module Feeds
  module OldTestGsdata
    class XmlWriter
      include Feeds::FeedConstants
      include Feeds::FeedHelper

      def initialize(data_reader, output_path)
        @root_element = 'gs-test-feed'
        @schema = 'http://www.greatschools.org/feeds/greatschools-test.xsd'
        @feed_file_path = output_path
        @data_reader = data_reader
      end

      def write_feed
        within_root_node do
          write_test_info
          write_state_info
          write_school_info
          write_district_info
        end
        close_file
      end

      private

      def write_test_info
        @data_reader.each_state_test do |hash|
          within_tag('test') do
            xml_builder.tag!('id', test_id(hash['test-id']))
            xml_builder.tag!('test-name', hash['test-name'])
            xml_builder.tag!('test-abbr', hash['test-abbr'])
            xml_builder.tag!('scale', hash['scale'])
            xml_builder.tag!('most-recent-year', hash['most-recent-year'])
            xml_builder.tag!('level-code', 'e,m,h')
            xml_builder.tag!('description', hash['description'])
          end
        end
      end

      def write_state_info
        @data_reader.each_state_result do |hash|
          within_tag('test-result') do
            write_test_result(state_uid, test_id(hash['test-id']), hash)
          end
        end
      end

      def write_district_info
        @data_reader.each_district_result do |hash|
          within_tag('test-result') do
            write_test_result(district_uid(hash['district-id']), test_id(hash['test-id']), hash)
          end
        end
      end

      def write_school_info
        @data_reader.each_school_result do |hash|
          within_tag('test-result') do
            write_test_result(school_uid(hash['school-id']), test_id(hash['test-id']), hash)
          end
        end
      end

      def write_test_result(uid, test_id, hash)
        xml_builder.tag!('universal-id', uid)
        xml_builder.tag!('test-id', test_id)
        xml_builder.tag!('year', hash['year'])
        xml_builder.tag!('subject-name', hash['subject-name'])
        xml_builder.tag!('grade-name', hash['grade'])
        xml_builder.tag!('level-code-name', 'e,m,h')
        xml_builder.tag!('score', hash['score'])
        xml_builder.tag!('proficiency-band-id', hash['proficiency-band-id'])
        xml_builder.tag!('proficiency-band-name', hash['proficiency-band-name'])
        xml_builder.tag!('number-tested', hash['number-tested']) unless hash['number-tested'].nil?
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
