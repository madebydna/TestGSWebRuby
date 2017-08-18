require_relative '../feed_config/feed_constants'

module Feeds
  class Arguments
    include Feeds::FeedConstants
    attr_accessor :states, :feed_names, :batch_size, :school_ids, :district_ids, :location, :names

    def initialize(arguments_string)
      arguments = parse_arguments(arguments_string)
      usage unless arguments.present?
      arguments.each { |key, value| send "#{key}=", value }
    end

    private

     def options_for_generating_all_feeds
       {
          :states => all_states,
          :feed_names => all_feeds,
          :batch_size =>  DEFAULT_BATCH_SIZE
       }
     end

     def parse_arguments(arguments_string)
       # To Generate All feeds for all states in current directory do rails runner script/feeds/feed_scripts/generate_feed_files.rb all
       if arguments_string == 'all'
         options_for_generating_all_feeds
       else
         feed_names, states, school_ids, district_ids, location, names, batch_size = arguments_string.try(:split, ':')
         states = states == 'all' ? all_states : split_argument(states)
         feed_names = feed_names == 'all' ? all_feeds : split_argument(feed_names)
         return false unless (feed_names-all_feeds).empty?
         return false unless (states.map(&:upcase)-all_states.map(&:upcase)).empty?
          {
               :states => states,
               :feed_names => feed_names,
               :school_ids => split_argument(school_ids),
               :district_ids => split_argument(district_ids),
               :location => location,
               :names => split_argument(names),
               :batch_size => batch_size.present? ? batch_size : DEFAULT_BATCH_SIZE
          }
       end
     end

     def split_argument(argument)
       argument.try(:split, ',') || argument
     end

    def usage
      abort "\n\nUSAGE: rails runner script/generate_feed_files(all | [feed_name]:[state]:[school_id]:[district_id]:[location]:[name]:[batch-size])

      Ex: rails runner script/generate_feed_files.rb test_scores:ca:1,2:1,2:'/tmp/':test_score_feed_test:5 (generates test_score file for state of CA , school id 1,2 , district id 1,2 at location /tmp/ with name as  <state>_test_score_feed batching 5 schools at a time)

      Possible feed  files: #{all_feeds.join(', ')}\n\n"
    end

  end
end