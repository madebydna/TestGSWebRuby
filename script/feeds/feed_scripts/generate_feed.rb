# frozen_string_literal: true

require_relative '../feed_config/feed_constants'
require_relative '../feed_helpers/feed_helper'
require_relative '../feed_helpers/feed_logger'
require_relative '../feed_helpers/feeds_option_parser'

require_relative '../feed_builders/subrating/data_reader'
require_relative '../feed_builders/subrating/xml_writer'
require_relative '../feed_builders/subrating/csv_writer'
require_relative '../feed_builders/subrating/csv_writer_description'

require_relative '../feed_builders/new-test-gsdata/data_reader'
require_relative '../feed_builders/new-test-gsdata/all_students_data_reader'
require_relative '../feed_builders/new-test-gsdata/xml_writer'
require_relative '../feed_builders/new-test-gsdata/subgroups_xml_writer'
require_relative '../feed_builders/new-test-gsdata/csv_writer'
require_relative '../feed_builders/new-test-gsdata/subgroups_csv_writer'

require_relative '../feed_builders/official_overall_rating/data_reader'
require_relative '../feed_builders/official_overall_rating/xml_writer'
require_relative '../feed_builders/official_overall_rating/csv_writer'
require_relative '../feed_builders/official_overall_rating/csv_writer_description'

module Feeds
  class GenerateFeed
    DATA_READERS = {
        subrating: Feeds::Subrating::DataReader,
        subrating_description: Feeds::Subrating::DataReader,
        new_test_gsdata: Feeds::NewTestGsdata::AllStudentsDataReader,
        new_test_subgroup_gsdata: Feeds::NewTestGsdata::DataReader,
        official_overall_rating: Feeds::OfficialOverallRating::DataReader,
        official_overall_rating_description: Feeds::OfficialOverallRating::DataReader,
    }

    DATA_WRITERS = {
        subrating: {
            xml: Feeds::Subrating::XmlWriter,
            txt: Feeds::Subrating::CsvWriter,
            csv: Feeds::Subrating::CsvWriter
        },
        subrating_description: {
            txt: Feeds::Subrating::CsvWriterDescription,
            csv: Feeds::Subrating::CsvWriterDescription
        },
        new_test_gsdata: {
            xml: Feeds::NewTestGsdata::XmlWriter,
            csv: Feeds::NewTestGsdata::CsvWriter,
            txt: Feeds::NewTestGsdata::CsvWriter
        },
        new_test_subgroup_gsdata: {
            xml: Feeds::NewTestGsdata::SubgroupsXmlWriter,
            csv: Feeds::NewTestGsdata::SubgroupsCsvWriter,
            txt: Feeds::NewTestGsdata::SubgroupsCsvWriter
        },
        official_overall_rating: {
            xml: Feeds::OfficialOverallRating::XmlWriter,
            txt: Feeds::OfficialOverallRating::CsvWriter,
            csv: Feeds::OfficialOverallRating::CsvWriter
        },
        official_overall_rating_description: {
            txt: Feeds::OfficialOverallRating::CsvWriterDescription,
            csv: Feeds::OfficialOverallRating::CsvWriterDescription
        },
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

    def district_ids
      @options[:district_ids]
    end

    def schools(state)
      if school_ids.present?
        School.find_by_state_and_ids(state, school_ids)
      else
        School.on_db(state.downcase.to_sym).active.not_preschool_only.order(:id)
      end
    end

    def districts(state)
      if district_ids.present?
        District.find_by_state_and_ids(state, district_ids)
      else
        District.on_db(state.downcase.to_sym).active.order(:id)
      end
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
        hash[s] = reader.new(s, schools(s), districts(s))
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