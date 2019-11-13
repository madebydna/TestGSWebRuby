# frozen_string_literal: true

module Feeds
  module OfficialOverallRating
    class XmlWriter
      include Feeds::FeedConstants
      include Feeds::FeedHelper

      def initialize(data_reader, output_path)
        @root_element = 'gs-official-overall-rating-feed'
        @schema = 'http://www.greatschools.org/feeds/gs-official-overall-rating.xsd'
        @feed_file_path = output_path
        @data_reader = data_reader
      end

      def write_feed
        within_root_node do
          write_state_info
          write_schools_info
        end
        close_file
      end

      private

      def write_state_info
        state_results = @data_reader.state_results
        within_tag('test-rating') do
          xml_builder.tag!('id', state_results['id'])
          xml_builder.tag!('year', state_results['year'])
          xml_builder.tag!('description', state_results['description'])
        end
      end

      def write_schools_info
        @data_reader.each_result { |hash| write_school_info(hash) if hash[:rating].present? }
      end

      def write_school_info(school_hash)
        write_xml_tag(school_hash, 'test-rating-value')
        # within_tag('test-rating-value') do
        #     xml_builder.tag!('universal-id', school_hash[:id].to_s)
        #     xml_builder.tag!('test-rating-id', school_hash[:test_rating_id].to_s)
        #     xml_builder.tag!('rating', school_hash[:rating].to_s)
        #     xml_builder.tag!('url', school_hash[:url].to_s)
        #   end
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
    end
  end
end
