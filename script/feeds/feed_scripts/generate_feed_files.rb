$LOAD_PATH.unshift File.dirname(__FILE__)
require_relative '../feed_helpers/feed_helper'
require_relative '../feed_helpers/feed_data_helper'
require_relative '../feed_helpers/arguments'
require_relative '../feed_helpers/feed_logger'

require_relative '../feed_config/feed_constants'

require_relative '../feed_builders/test_score/test_score_feed'
require_relative '../feed_builders/rating/test_rating_feed'



module Feeds
  class GenerateFeedFiles
    include Feeds::FeedHelper
    include Feeds::FeedConstants

    def self.generate
      GenerateFeedFiles.new.generate
    end

    def generate
      arguments = Feeds::Arguments.new(ARGV[0])
      arguments.states.each do |state|
        begin
          Feeds::FeedLog.log.debug "Starting Feed Generation for state #{state}"
          generate_all_feeds(arguments.district_ids, arguments.school_ids, arguments.batch_size,state,arguments.feed_names,
                             arguments.locations,arguments.names)
          Feeds::FeedLog.log.debug "Ending Feed Generation for state #{state}"
        rescue => e
          Feeds::FeedLog.log.error e
          raise e
        end
      end
    end

    def generate_all_feeds(district_ids,school_ids,batch_size,state,feed_names,locations,names)
      feed_names.each_with_index do |feed, index|
            begin
            feed_opts = {state: state,
                         school_ids: school_ids,
                         district_ids: district_ids,
                         feed_file: get_feed_name(feed, index,locations,names,state),
                         batch_size: batch_size,
                         schema: FEED_TO_SCHEMA_MAPPING[feed],
                         root_element: FEED_TO_ROOT_ELEMENT_MAPPING[feed],
                         ratings_id_for_feed: RATINGS_ID_RATING_FEED_MAPPING[feed],
                         data_type: DATA_TYPE_TEST_SCORE_FEED_MAPPING[feed],
                         }
              start_time = Time.now
              Feeds::FeedLog.log.debug "--- Start Time for generating feed: FeedType: #{feed}  for state #{state} --- #{Time.now}"
              feed_generation_class(feed).new(feed_opts).generate_feed
              Feeds::FeedLog.log.debug "--- Time taken to generate feed : FeedType: #{feed}  for state #{state} --- #{Time.at((Time.now-start_time).to_i.abs).utc.strftime '%H:%M:%S:%L'}"
            rescue => e
              Feeds::FeedLog.log.error e
              raise e
            end
     end
    end

    def feed_generation_class(key)
      {
          test_scores:       Feeds::TestScoreFeed,
          test_subgroup:     Feeds::TestScoreFeed,
          test_rating:       Feeds::TestRatingFeed,
          official_overall:  Feeds::TestRatingFeed
      }[key.to_s.to_sym]
    end
  end
  GenerateFeedFiles.generate
end
