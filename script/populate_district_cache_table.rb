def all_cache_keys
  ['ratings','feed_test_scores', 'district_schools_summary']
end

def all_states
  States.abbreviations
end

def usage
  abort "\n\nUSAGE: rails runner script/populate_district_cache_table (all | [state]:[cache_keys]:[districts_where])

Ex: rails runner script/populate_district_cache_table al:feed_test_scores de:all:9,18,23
Ex: rails runner script/populate_district_cache_table al:feed_test_scores de:all:\"id IN (9,18,23)\"

Possible cache keys: #{all_cache_keys.join(', ')}\n\n"
end



def parse_arguments
  # Returns false or parsed arguments
  if ARGV[0] == 'all' && ARGV[1].nil?
    [{
         states: all_states,
         cache_keys: all_cache_keys
     }]
  else
    args = []
    ARGV.each_with_index do |arg, i|
      state,cache_keys,districts_where = arg.split(':')
      return false unless all_states.include?(state) || state == 'all'
      state = state == 'all' ? all_states : [state]
      cache_keys ||= 'none_given'
      cache_keys = cache_keys.split(',')
      cache_keys = all_cache_keys if cache_keys == ['all']
      cache_keys.each do |cache_key|
        return false unless all_cache_keys.include?(cache_key)
      end
      if districts_where
        if !districts_where.include?(' ')
          districts_where = { id: districts_where.split(',') }
        end
      end
      args[i] = {}
      args[i][:states] = state
      args[i][:cache_keys] = cache_keys
      args[i][:districts_where] = districts_where if districts_where.present?
    end
    args
  end
end

parsed_arguments = parse_arguments

usage unless parsed_arguments.present?

parsed_arguments.each do |args|
  states = args[:states]
  cache_keys = args[:cache_keys]
  districts_where = args[:districts_where]
  states.each do |state|
    cache_keys.each do |cache_key|
      if districts_where
        District.on_db(state.downcase.to_sym).where(districts_where).each do |district|
          DistrictCacher.create_cache(district, cache_key)
        end
      else
        District.on_db(state.downcase.to_sym).all.each do |district|
          DistrictCacher.create_cache(district, cache_key)
        end
      end
    end
  end
end
