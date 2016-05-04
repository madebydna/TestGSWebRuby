require_relative '../feed_config/feed_constants'

module Feeds
  class Arguments

    include FeedConstants
    attr_accessor :states, :feed_names, :batch_size, :school_ids, :district_ids,:locations ,:names

    def initialize()
      arguments = parse_arguments
      usage unless arguments.present?
      arguments.each { |key, value| send "#{key}=", value }
    end

    private

     def options_for_generating_all_feeds
       [{  states: all_states, feed_names: all_feeds}]
     end

     def parse_arguments
       # To Generate All feeds for all states in current directory do rails runner script/feeds/feed_scripts/generate_feed_files.rb all
       if ARGV[0] == 'all' && ARGV[1].nil?
         OPTIONS_FOR_GENERATING_ALL_FEEDS
       else
         feed_names, states, school_ids, district_ids, locations, names, batch_size= ARGV[0].try(:split, ':')
         states = states == 'all' ? all_states : split_argument(states)
         feed_names = feed_names == 'all' ? all_feeds : split_argument(feed_names)
         return false unless (feed_names-all_feeds).empty?
         return false unless (states-all_states).empty?
         args = {
             :states => states,
             :feed_names => feed_names,
             :school_ids => split_argument(school_ids),
             :district_ids => split_argument(district_ids),
             :locations => split_argument(locations),
             :names => split_argument(names),
             :batch_size => batch_size.present? ? batch_size : DEFAULT_BATCH_SIZE

         }
       end
     end

     def split_argument(argument)
       argument.try(:split, ",") || argument
     end

  end
end