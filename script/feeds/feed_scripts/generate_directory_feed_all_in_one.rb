# frozen_string_literal: true

require_relative '../../../lib/states'

module Feeds
  class GenerateDirectoryFeedAllInOne
    def initialize(path)
      @path = path
    end

    def output_file
      "#{@path}/local-greatschools-feed-allinone.xml"
    end

    def input_file(state)
      "#{@path}/local-greatschools-feed-#{state.upcase}.xml"
    end

    def states
      States.abbreviations
    end

    def file_header
      <<~HEADER
        <?xml version="1.0" encoding="utf-8"?>
        <gs-local-national-feed xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.greatschools.org/feeds/gs-local-national-feed.xsd">
      HEADER
    end

    def file_footer
      '</gs-local-national-feed>'
    end

    def reject_line?(line)
      if line.include?("<?xml version=") ||
          line.include?("<gs-local-feed xmlns:xsi=") ||
          line.include?("</gs-local-feed>") ||
          line.nil?
        true
      else
        false
      end
    end

    def generate
      File.open(output_file, 'w') do |out_file|
        # write top of xml for all in one
        out_file.puts file_header
        states.each do |state|
          out_file.puts '<gs-local-feed>'
          File.foreach(input_file(state)) do |line|
            # guard clause for beginning and end of file
            next if reject_line?(line)
            out_file.puts line
          end
          out_file.puts '</gs-local-feed>'
        end
        # write bottom of xml for all in one
        out_file.puts file_footer
      end
    end
  end
end

if ARGV[0]
  Feeds::GenerateDirectoryFeedAllInOne.new(ARGV[0]).generate
  exit 0
else
  puts "You need to include the path to the files, this is also where file will be created"
  exit 1
end

