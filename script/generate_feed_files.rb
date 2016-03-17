$LOAD_PATH.unshift File.dirname(__FILE__)
require 'feed_helper'

class GenerateFeedFiles
  include FeedHelper

  def self.generate
    GenerateFeedFiles.new.generate
  end

  def initialize()
    @parsed_arguments = parse_arguments
    usage unless @parsed_arguments.present?

  end

  def generate
    @parsed_arguments.each do |args|
      states = args[:states]
      feed_names = args[:feed_names]
      @school_ids = args[:school_id]
      @district_ids = args[:district_id]
      location = args[:location]
      name = args[:name]
      feed_names.each_with_index do |feed, index|
        states.each do |state|
          @state = state
          @feed_type = feed
          if feed == 'test_scores'
            @feed_location = location.present? && location[index].present? ? location[index] : 'default'
            @feed_name = name.present? && name[index].present? ? name[index] : 'local-gs-test-feed'
            generate_test_score_feed
          elsif feed == 'ratings'
            # To do Create the feed for ratings
            # @feed_location = location.present? && location[index].present? ? location[index] : 'default'
            # @feed_location = name.present? && name[index].present? ? name[index] : 'default'
            # generate_test_score_feed

          end
        end
      end
    end

  end
end


GenerateFeedFiles.generate()



