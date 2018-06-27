# frozen_string_literal: true

require_relative '../feed_config/feed_constants'
require_relative '../feed_helpers/feed_helper'
require_relative '../feed_helpers/feed_logger'
require_relative '../feed_helpers/feeds_option_parser'

require_relative '../feed_builders/subrating/data_reader'
require_relative '../feed_builders/subrating/xml_writer'

module Feeds
  class GenerateFeed
    DATA_READERS = {
        subrating: Feeds::Subrating::DataReader
    }

    DATA_WRITERS = {
        subrating: {
            xml: Feeds::Subrating::XmlWriter
        }
    }

    def initialize
      option_parser = Feeds::FeedsOptionParser.new
      @options = option_parser.parse!
    end

    def generate
      states.each do |state|
        formats.each do |format|
          write_feed(state, format)
        end
      end
    end

    private

    def school_ids
      @options[:school_ids]
    end

    def states
      Array.wrap(@options[:state] || States.abbreviations)
    end

    def formats
      @options[:formats]
    end

    def feed
      @options[:feed].to_sym
    end

    def output_filename(state, format)
      path = @options[:path] || ''
      filename = Feeds::FeedConstants::FEED_NAME_MAPPING[feed.to_s]
      raise "No filename found for #{feed}" unless filename.present?
      state_component = state ? "-#{state.upcase}" : ''

      "#{path}#{filename}#{state_component}.#{format}"
    end

    def data_reader(state)
      @_data_readers ||= Hash.new do |hash, s|
        reader = DATA_READERS[feed]
        raise "No data reader found for #{feed}" unless reader.present?
        hash[s] = reader.new(s, school_ids)
      end
      @_data_readers[state]
    end

    def data_writer(format, reader, filename)
      writer_map = DATA_WRITERS[feed]
      raise "No writer configurations found for #{feed}" unless writer_map.present?
      writer = writer_map[format]
      raise "No #{format} data writer found for #{feed}" unless writer.present?
      writer.new(reader, filename)
    end

    def write_feed(state, format)
      begin
        start_time = Time.now
        output_path = output_filename(state, format)
        Feeds::FeedLog.log.debug "Writing #{output_path} started #{start_time}"
        data_writer(format, data_reader(state), output_path).write_feed
        Feeds::FeedLog.log.debug "Done writing #{output_path}, took #{Time.at((Time.now-start_time).to_i.abs).utc.strftime '%H:%M:%S:%L'}"
      rescue Exception => e
        Feeds::FeedLog.log.error e
        raise
      end
    end
  end
end

Feeds::GenerateFeed.new.generate