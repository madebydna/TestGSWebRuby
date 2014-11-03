def all_cache_keys
  ['ratings','test_scores','characteristics', 'esp_responses', 'reviews_snapshot','progress_bar']
end

def nightly_states
  ['de','in']
end

def usage
  abort "\n\nUSAGE: rails runner script/populate_school_cache_table (all | [state]:[cache_keys]:[school_ids])

Ex: rails runner script/populate_school_cache_table al:test_scores de:all:9,18,23

Possible cache keys: #{all_cache_keys.join(', ')}\n\n"
end

def all_states
  States.abbreviations
end

def parse_arguments
  # Returns false or parsed arguments
  if ARGV[0] == 'all' && ARGV[1].nil?
    [{
         states: all_states,
         cache_keys: all_cache_keys
     }]
    # TODO Limit nightly cache keys
  else
    args = []
    ARGV.each_with_index do |arg, i|
      state,cache_keys,school_ids = arg.split(':')
      return false unless all_states.include?(state) || state == 'all'
      state = state == 'all' ? all_states : [state]
      cache_keys ||= 'none_given'
      cache_keys = cache_keys.split(',')
      cache_keys = all_cache_keys if cache_keys == ['all']
      cache_keys.each do |cache_key|
        return false unless all_cache_keys.include?(cache_key)
      end
      if school_ids
        school_ids = school_ids.split(',')
        school_ids.each do |school_id|
          return false unless school_id.numeric?
        end
      end
      args[i] = {}
      args[i][:states] = state
      args[i][:cache_keys] = cache_keys
      args[i][:school_ids] = school_ids if school_ids.present?
    end
    args
  end
end

parsed_arguments = parse_arguments

usage unless parsed_arguments

parsed_arguments.each do |args|
  states = args[:states]
  cache_keys = args[:cache_keys]
  school_ids = args[:school_ids]
  states.each do |state|
    # Remove the next line to have all mean all states again
    next if ARGV[0] == 'all' && !nightly_states.include?(state)
    cache_keys.each do |cache_key|
      if school_ids
        School.on_db(state.downcase.to_sym).where(id: school_ids).each do |school|
          Cacher.create_cache(school, cache_key)
        end
      else
        School.on_db(state.downcase.to_sym).all.each do |school|
          Cacher.create_cache(school, cache_key)
        end
      end
    end
  end
end

=begin
to do:
1. hashes of what data team wants -
2. separate json conversion from fetch
3. Make this a stand alone script

if data team changes schema, it shouldn't matter

- data team decides what's a rating
- rails code reads what they want and gets ratings from db
=end
