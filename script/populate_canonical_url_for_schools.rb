# frozen_string_literal: true

require 'optparse'

include Rails.application.routes.url_helpers
include UrlHelper

ARGV << '-h' if ARGV.empty?

script_args = {}
OptionParser.new do |opts|
  opts.banner = "Usage: This script records the canonical url to the school instance if one doesn't exist or update all schools' canonical url"
  opts.on("-s STATES", "--states STATES", String, 'comma separated states to index') { |s| script_args[:states] = s }
  opts.on("-u", "--update", String, 'update schools with missing canonical url in the db') { |u| script_args[:update] = u}
  opts.on("-r", "--refresh", String, "refreshes all schools' canonical url in the db") { |r| script_args[:refresh] = r}
  opts.on_tail("-h", "--help", "Show this message") { puts "Hello!"; puts opts; exit }
end.parse!

states_argument = script_args[:states] || States.state_hash.values.join(',')
states = states_argument.split(',')
should_refresh = script_args.has_key?(:refresh) ? true : false
should_update = script_args.has_key?(:update) ? true : false

raise ArgumentError.new("Can't refresh and update the database at the same time!") if should_refresh && should_update
raise ArgumentError.new("Need to give command to either update the database or refresh the database!") unless should_refresh || should_update
raise ArgumentError.new("Need to supply valid states!") unless states.all? {|s| States.state_hash.values.include?(s)}

counter = 0

begin log = ScriptLogger.record_log_instance(script_args); rescue;end

begin
  states.each do |state|
    School.on_db(state) do
      puts "Working on..."
      puts "......#{state}"
      if should_update
        School.active.where(canonical_url: nil).each do |school|
          # done this way since ActiveRecord#update and ActiveRecord#update_attributes seems bugged
          school.canonical_url  = school_path(school, trailing_slash: true)
          school.save
          counter += 1
        end
      elsif should_refresh
        School.active.each do |school|
          # done this way since ActiveRecord#update and ActiveRecord#update_attributes seems bugged
          # send a param to school_path to not use the canonical_url found in the db
          school.canonical_url  = school_path(school, trailing_slash: true, refresh_canonical_link: should_refresh)
          school.save
          counter += 1
        end
      end
    end
  end

  begin log.finish_logging_session(1, "Updated #{counter} canonical urls"); rescue;end

rescue => e
  begin log.finish_logging_session(0, e); rescue;end
  raise
rescue SignalException
  begin log = log.finish_logging_session(0, "Process ended early. User manually cancelled process."); rescue;end
  abort
end

puts "Updated #{counter} canonical urls"