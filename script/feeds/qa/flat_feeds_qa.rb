#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'
require 'feeds/feed_config'
require 'feeds/qa/flat_feed_validator'

# parse arguments and store them into an options hash
ARGV << '-h' if ARGV.empty?
script_args = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [script_args]"
  opts.on("-r RELEASE", "--release RELEASE", String, 'release ID such as r999') { |r| script_args[:release_id] = r }
  opts.on("-p PREVIOUS_RELEASE", "--previous PREVIOUS_RELEASE", String, 'full ID for previous release') { |p| script_args[:previous_release_id] = p }
  opts.on("-a ARCHIVE_DIRECTORY", "--archive ARCHIVE_DIRECTORY", String, 'path to directory where feeds are archived') { |p| script_args[:archive_directory] = p }
  opts.on_tail("-h", "--help", "Show this message") { puts opts; exit }
end.parse!

feed_config = FeedConfig.new(
  release_id: script_args[:release_id],
  previous_release_id: script_args[:previous_release_id],
  archive_directory: script_args[:archive_directory] || File.join('/', 'home', 'feeds', 'archive')
)

class FlatFeedQa
  def initialize(feed_config:)
    @feed_config = feed_config
    @flat_feed_validator = FlatFeedValidator.new(feed_config: feed_config)
    @success = true
  end

  def qa
    results = @flat_feed_validator.verify
    @success = false if results.any?
    results.each { |result| puts result }
    results
  end

  def success?
    @success == true
  end
end

qa_runner = FlatFeedQa.new(feed_config: feed_config)
qa_runner.qa
qa_runner.success? ? exit(0) : exit(1)