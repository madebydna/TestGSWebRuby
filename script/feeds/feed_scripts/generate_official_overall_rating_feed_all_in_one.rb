# frozen_string_literal: true

require_relative '../../../lib/states'

module Feeds
  class GenerateOfficialOverallRatingFeedAllInOne
    def initialize(path)
      @path = path
    end

    def output_file
      "#{@path}/local-gs-official-overall-rating-feed-allinone.xml"
    end

    def input_file(state)
      "#{@path}/local-gs-official-overall-rating-feed-#{state.upcase}.xml"
    end

    def states
      States.abbreviations
    end

    def file_header
      <<~HEADER
        <?xml version="1.0" encoding="utf-8"?>
        <gs-national-official-overall-rating-feed xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.greatschools.org/feeds/gs-national-official-overall-rating-feed.xsd">
      HEADER
    end

    def file_footer
      "</gs-national-official-overall-rating-feed>"
    end

    def reject_line?(line)
      line.nil? ||
          line.strip == "" ||
          line.include?("<?xml version=") ||
          line.include?("<gs-official-overall-rating-feed xmlns:xsi=") ||
          line.include?("</gs-official-overall-rating-feed>")
    end

    def generate
      File.open(output_file, 'w') do |out_file|
        # write top of xml for all in one
        out_file.puts file_header
        states.each do |state|
          out_file.puts '<gs-official-overall-rating-feed>'
          File.foreach(input_file(state)) do |line|
            # guard clause for beginning and end of file
            next if reject_line?(line)
            out_file.puts line
          end
          out_file.puts '</gs-official-overall-rating-feed>'
        end
        # write bottom of xml for all in one
        out_file.puts file_footer
      end
    end
  end
end

if ARGV[0]
  Feeds::GenerateOfficialOverallRatingFeedAllInOne.new(ARGV[0]).generate
  exit 0
else
  puts "You need to include the path to the files, this is also where the all in one file will be created"
  exit 1
end

