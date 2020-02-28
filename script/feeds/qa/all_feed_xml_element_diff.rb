# frozen_string_literal: true

require 'xml_diff/sax_handler'
require 'xml_diff/sax_parser'
require 'xml_diff/xml_element_report_generator'

class AllFeedXmlElementDiff
  attr_reader :feed_config
  def initialize(feed_config:)
    @feed_config = feed_config
  end

  def xml_element_diff
    all_entries_over_threshhold = []

    feed_config.each_pair_old_and_new_feed_files do |old_file, new_file|
      new_file_report_generator = XmlDiff::XmlElementReportGenerator.new(
        parser: XmlDiff::SaxParser.new(file: new_file, handler: XmlDiff::SaxHandler.new)
      )
      entries_over_threshhold = new_file_report_generator.compare(
        XmlDiff::SaxParser.new(file: old_file, handler: XmlDiff::SaxHandler.new).parse
      # ).select { |element, difference| difference > 0.1 }
      ).select { |element, difference| difference > 0.0}
       .map { |e, d| "#{old_file} #{new_file} #{e} #{d}" }
       .sort

      all_entries_over_threshhold.concat(entries_over_threshhold)
    end

    all_entries_over_threshhold
  end
end
