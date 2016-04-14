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
      @batch_size = args[:batch_size]
      @school_ids = args[:school_id]
      @district_ids = args[:district_id]
      location = args[:location]
      name = args[:name]



      feed_names.each_with_index do |feed, index|
        states.each do |state|
          @state = state
          @feed_type = feed
          @batch_size = @batch_size.present? ? @batch_size : DEFAULT_BATCH_SIZE
          # Generate School Batches
          @school_batches ||= get_school_batches
          # Generate District Batches
          @district_batches ||=  get_district_batches
          if feed == 'test_scores'
            @feed_location = location.present? && location[index].present? ? location[index] : 'default'
            @feed_name = name.present? && name[index].present? ? name[index] : FEED_NAME_MAPPING[feed]
            generate_test_score_feed
          elsif feed == 'test_rating'
            @feed_location = location.present? && location[index].present? ? location[index] : 'default'
            @feed_name = name.present? && name[index].present? ? name[index] : FEED_NAME_MAPPING[feed]
            generate_test_rating_feed
          end
        end
      end
    end

  end
end


GenerateFeedFiles.generate()



