#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'
require 'yaml'
require 'open3'
require 'feeds/feed_config'
require 'feeds/qa/all_feed_xml_element_diff'

# parse arguments and store them into an options hash
ARGV << '-h' if ARGV.empty?
script_args = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [script_args]"
  opts.on("-r RELEASE", "--release RELEASE", String, 'release ID such as r999') { |r| script_args[:release_id] = r }
  opts.on("-p PREVIOUS_RELEASE", "--previous PREVIOUS_RELEASE", String, 'full ID for previous release') { |p| script_args[:previous_release_id] = p }
  opts.on_tail("-h", "--help", "Show this message") { puts opts; exit }
end.parse!

feed_config = FeedConfig.new(
  release_id: script_args[:release_id],
  previous_release_id: script_args[:previous_release_id]
)

class FeedQa
  def initialize(feed_config:)
    @feed_config = feed_config
    @all_feed_xml_element_diff = AllFeedXmlElementDiff.new(feed_config: feed_config)
    @success = true
  end

  def qa
    results = @all_feed_xml_element_diff.xml_element_diff
    @success = false if results.any?
    results.each { |result| puts result }
    results
  end

  def success?
    @success == true
  end
end

qa_runner = FeedQa.new(feed_config: feed_config)
qa_runner.qa
qa_runner.success? ? exit(0) : exit(1)
