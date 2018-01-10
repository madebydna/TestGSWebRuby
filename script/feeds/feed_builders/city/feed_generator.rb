require_relative '../../feed_config/feed_constants'
require_relative 'xml_writer'
require_relative 'data_reader'

require 'states'

module Feeds
  module City
    class FeedGenerator 
      include Feeds::FeedConstants

      attr_accessor :state, :city_feed

      def initialize(attributes = {})
        state = attributes[:state]
        feed_file_path = attributes[:feed_file]
        root_element = attributes[:root_element]
        schema = attributes[:schema]

        @data_reader = DataReader.new(state)
        @writers = {
          xml: XmlWriter.new(root_element, schema, feed_file_path)
        }
      end

      def generate_feed(format = :xml)
        raise 'Feed format not supported' unless @writers[format]
        @writers[format].write_feed(@data_reader, [
          :id,:name, :state, :rating, :url, :lat, :lon, :active
        ])
      end


    end
  end
end
