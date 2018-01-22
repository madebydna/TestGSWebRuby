# frozen_string_literal: true

require_relative '../../feed_config/feed_constants'
require_relative 'xml_writer'
require_relative 'proficiency_band_data_reader'
require_relative 'proficiency_band_group_data_reader'

require 'states'

module Feeds
  module ProficiencyBand
    class FeedGenerator 
      include Feeds::FeedConstants

      attr_accessor :state, :proficiency_band_feed

      def initialize(attributes = {})
        state = attributes[:state]
        feed_file_path = attributes[:feed_file]
        root_element = attributes[:root_element]
        schema = attributes[:schema]

        @proficiency_band_data_reader = Feeds::ProficiencyBand::ProficiencyBandDataReader.new(state)
        @proficiency_band_group_data_reader = Feeds::ProficiencyBand::ProficiencyBandGroupDataReader.new(state)
        @writers = {
          xml: XmlWriter.new(root_element, schema, feed_file_path)
        }
      end

      def generate_feed(format = :xml)
        raise 'Feed format not supported' unless @writers[format]
        @writers[format].write_feed(@proficiency_band_data_reader, @proficiency_band_group_data_reader)
      end
    end
  end
end
