# frozen_string_literal: true

require 'optparse'

module Feeds
  class FeedsOptionParser
    include Feeds::FeedConstants

    attr_reader :options

    def initialize
      @options = {}
      @options[:formats] = []

      @option_parser = OptionParser.new

      @option_parser.banner = "Usage: rails runner #{$0} -f FEED [options]"

      @option_parser.on('-?', 'Prints this help') do
        puts @option_parser
        exit
      end

      @option_parser.on('-f', '--feed FEED', VALID_FEED_NAMES,
                        "Feed to build, one of (#{VALID_FEED_NAMES.join(', ')})") do |f|
        @options[:feed] = f
      end

      @option_parser.on('-o', '--output PATH', 'Output path, defaults to current dir') do |path|
        @options[:path] = path
      end

      @option_parser.on('-s', '--state STATE', States.abbreviations, 'State abbreviation, defaults to all') do |state|
        @options[:state] = state
      end

      @option_parser.on('-i', '--schoolids IDS', 'School IDs, defaults to all') do |school_ids|
        @options[:school_ids] = school_ids.split(',').map(&:to_i)
      end

      @option_parser.on('-d', '--districtids IDS', 'District IDs, defaults to all') do |district_ids|
        @options[:district_ids] = district_ids.split(',').map(&:to_i)
      end

      @option_parser.on('-t', '--type FORMAT', VALID_FEED_FORMATS,
                        "Output formats, defaults to xml. From (#{VALID_FEED_FORMATS.join(', ')})") do |format|
        @options[:formats] << format.to_sym
      end
    end

    def parse!
      @option_parser.parse!
      unless @options[:feed].present?
        puts 'Error: Feed is required'
        puts @option_parser
        exit 1
      end
      @options[:formats] << :xml if @options[:formats].empty?
      @options[:path] ||= ''
      @options
    end
  end
end