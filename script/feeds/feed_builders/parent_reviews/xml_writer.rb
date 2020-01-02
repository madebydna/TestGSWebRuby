# frozen_string_literal: true

module Feeds
  module ParentReview
    class XmlWriter
      include Feeds::FeedConstants
      include Feeds::FeedHelper

      def initialize(data_reader, output_path)
        @root_element = 'gs-parent-review-feed'
        @schema = 'http://www.greatschools.org/feeds/local-gs-parent-review.xsd'
        @feed_file_path = output_path
        @data_reader = data_reader
      end

      def write_feed
        within_root_node do
          write_rating_summaries
          write_review_info
        end
        close_file
      end

      private

      def write_rating_summaries
        rating_summaries = @data_reader.rating_summaries

        rating_summaries.each do |school_id, data_hash|
          within_tag('ratings-summary') do
            xml_builder.tag!('universal-id', data_hash['universal-id'])
            xml_builder.tag!('count', data_hash['count'])
            xml_builder.tag!('avg-quality', data_hash['avg-quality'])
          end
        end
      end

      def write_review_info
        reviews = @data_reader.reviews

        reviews.each do |review|
          within_tag('review') do
            xml_builder.tag!('universal-id', review['universal-id'])
            xml_builder.tag!('id', review['id'])
            xml_builder.tag!('who', review['who'])
            xml_builder.tag!('posted', review['posted'])
            xml_builder.tag!('comments', review['comments'])
            xml_builder.tag!('quality', review['quality'])
            xml_builder.tag!('url', review['url'])
          end
        end
      end

      def file
        @_file ||= File.open(@feed_file_path, 'w')
      end

      def xml_builder
        @_xml_builder ||= begin
          xml = Builder::XmlMarkup.new(:target => file, :indent => 1)
          xml.instruct! :xml, :version => '1.0', :encoding => 'utf-8'
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
    end
  end
end
