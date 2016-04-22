$LOAD_PATH.unshift File.dirname(__FILE__)
require_relative '../../feeds/feed_helpers/feed_helper'
require_relative '../../feeds/feed_helpers/feed_data_helper'
require_relative '../../feeds/feed_config/feed_constants'

require_relative '../../feeds/feed_builders/test_score_feed'
require_relative '../../feeds/feed_builders/test_rating_feed'


module FeedScripts
  class GenerateFeedFiles
    include FeedHelper
    include FeedDataHelper
    include FeedConstants

    def self.generate
      GenerateFeedFiles.new.generate
    end

    def initialize()
      @parsed_arguments = parse_arguments
      usage unless @parsed_arguments.present?
      @parsed_arguments.each do |args|
        @states = args[:states]
        @feed_names = args[:feed_names]
        @batch_size = args[:batch_size].present? ? args[:batch_size] : DEFAULT_BATCH_SIZE
        @school_ids = args[:school_id]
        @district_ids = args[:district_id]
        @location = args[:location]
        @name = args[:name]
      end
    end

    def generate
      @states.each do |state|
        @state = state
        # Generate School Batches
        school_batches = get_school_batches
        # Generate District Batches
        district_batches = get_district_batches
        generate_all_feeds(district_batches, school_batches, state)
      end
    end

    def generate_all_feeds(district_batches, school_batches, state)
      @feed_names.each_with_index do |feed, index|
        # Get Feed Name
        feed_file = get_feed_name(feed, index)
        feed_opts = {state: state,
                     school_batches: school_batches,
                     district_batches: district_batches,
                     feed_type: feed,
                     feed_file: feed_file,
                     schema: FEED_TO_SCHEMA_MAPPING[feed],
                     root_element: FEED_TO_ROOT_ELEMENT_MAPPING[feed],
                     ratings_id_for_feed: RATINGS_ID_RATING_FEED_MAPPING[feed]
        }
        feed_generation_class = get_feed_generation_class(feed)
        feed_generation_class.new(feed_opts).generate_feed
      end
    end

    def get_feed_generation_class(key)
      {
          test_scores:       FeedBuilders::TestScoreFeed,
          test_rating:       FeedBuilders::TestRatingFeed,
          official_overall:  FeedBuilders::TestRatingFeed
      }[key.to_s.to_sym]
    end
  end
GenerateFeedFiles.generate()
end