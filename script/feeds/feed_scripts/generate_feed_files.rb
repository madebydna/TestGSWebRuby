$LOAD_PATH.unshift File.dirname(__FILE__)
require_relative '../feed_helpers/feed_helper'
require_relative '../feed_helpers/feed_data_helper'
require_relative '../feed_helpers/arguments'


require_relative '../feed_config/feed_constants'

require_relative '../feed_builders/test_score/test_score_feed'
require_relative '../feed_builders/test_score/test_score_subgroup_feed'
require_relative '../feed_builders/rating/test_rating_feed'



module FeedScripts
  class GenerateFeedFiles
    include FeedHelper
    include FeedDataHelper
    include FeedConstants

    def self.generate
      GenerateFeedFiles.new.generate
    end

    def generate
      arguments = Feeds::Arguments.new
      arguments.states.each do |state|
        state = state
        # Generate School Batches
        school_batches = get_school_batches(state,arguments.school_ids,arguments.batch_size)
        # Generate District Batches
        district_batches = get_district_batches(state,arguments.district_ids,arguments.batch_size)
        generate_all_feeds(district_batches, school_batches, state,arguments.feed_names, arguments.locations,arguments.names)
      end
    end

    def generate_all_feeds(district_batches, school_batches, state,feed_names,locations,names)
      feed_names.each_with_index do |feed, index|
        # Get Feed Name
        feed_file = get_feed_name(feed, index,locations,names,state)
        feed_opts = {state: state,
                     school_batches: school_batches,
                     district_batches: district_batches,
                     feed_type: feed,
                     feed_file: feed_file,
                     schema: FEED_TO_SCHEMA_MAPPING[feed],
                     root_element: FEED_TO_ROOT_ELEMENT_MAPPING[feed],
                     ratings_id_for_feed: RATINGS_ID_RATING_FEED_MAPPING[feed]
        }
        feed_generation_class(feed).new(feed_opts).generate_feed
      end
    end

    def feed_generation_class(key)
      {
          test_scores:       FeedBuilders::TestScoreFeed,
          test_subgroup:     FeedBuilders::TestScoreSubgroupFeed,
          test_rating:       FeedBuilders::TestRatingFeed,
          official_overall:  FeedBuilders::TestRatingFeed
      }[key.to_s.to_sym]
    end
  end
GenerateFeedFiles.generate()
end