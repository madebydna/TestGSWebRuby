$LOAD_PATH.unshift File.dirname(__FILE__)
require_relative '../../feeds/feed_helpers/feed_helper'
require_relative '../../feeds/feed_builders/test_score_feed'
require_relative '../../feeds/feed_builders/test_rating_feed'
require_relative '../../feeds/feed_config/feed_constants'


module FeedScripts
  class GenerateFeedFiles
    include FeedHelpers
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
          @feed_names.each_with_index do |feed, index|
            # Get Feed Name
            feed_file = get_feed_name(feed, index)
            feed_opts = {state: state,
                         school_batches: school_batches,
                         district_batches: district_batches,
                         feed_type: feed,
                         feed_file: feed_file
            }
            if feed == 'test_scores'
              test_scores_feed_opts = {root_element: 'gs-test-feed',
                                       schema: 'http://www.greatschools.org/feeds/greatschools-test.xsd'
                                      }
              feed_opts.merge!(test_scores_feed_opts)
              FeedBuilders::TestScoreFeed.new(feed_opts).generate_feed
            elsif feed == 'test_rating'
              test_rating_feed_opts = {root_element: 'gs-test-rating-feed',
                                       schema: 'http://www.greatschools.org/feeds/greatschools-test-ratings.xsd',
                                       ratings_id_for_feed:  RATINGS_ID_RATING_FEED_MAPPING[feed]
                                       }
              feed_opts.merge!(test_rating_feed_opts)
              FeedBuilders::TestRatingFeed.new(feed_opts).generate_feed
            elsif feed == 'official_overall'
              official_overall_rating_feed_opts = {root_element: 'gs-official-overall-rating-feed',
                                       schema: 'http://www.greatschools.org/feeds/greatschools-test-ratings.xsd',
                                       ratings_id_for_feed:  RATINGS_ID_RATING_FEED_MAPPING[feed]
              }
              feed_opts.merge!(official_overall_rating_feed_opts)
              FeedBuilders::TestRatingFeed.new(feed_opts).generate_feed
            end
          end
      end
    end
  end
GenerateFeedFiles.generate()
end