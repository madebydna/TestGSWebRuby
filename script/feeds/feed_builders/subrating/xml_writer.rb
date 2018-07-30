# frozen_string_literal: true

module Feeds
  module Subrating
    class XmlWriter
      include Feeds::FeedConstants
      include Feeds::FeedHelper

      def initialize(data_reader, output_path)
        @root_element = 'gs-subrating-feed'
        @schema = 'http://www.greatschools.org/feeds/gs-subrating.xsd'
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
        within_tag('state') do
          xml_builder.tag!('universal-id', state_uid)

          within_tag('rating-infos') do
            @data_reader.state_results.each_value do |rating_info|
              write_xml_tag(rating_info, 'rating-info')
            end
          end
        end
      end

      def write_schools_info
        within_tag('schools') do
          @data_reader.each_result { |hash| write_school_info(hash) }
        end
      end

      def write_school_info(school_hash)
        unless school_hash[:ratings].empty?
          within_tag('school') do
            xml_builder.tag!('universal-id', school_uid(school_hash[:id]))
            xml_builder.tag!('url', school_hash[:url])
            write_school_ratings(school_hash[:ratings])
          end
        end
      end

      def write_school_ratings(ratings_hash)
        within_tag('ratings') do
          ratings_hash.each do |rating_name, rating_obj|
            write_xml_tag({
                              name: rating_name.to_s,
                              value: rating_obj.school_value
                          }, 'rating')
          end
        end
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

      def state_uid
        transpose_universal_id(@data_reader.state, nil, nil)
      end
    end
  end
end
