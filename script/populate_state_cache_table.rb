had_any_errors = false

def all_cache_keys
  %w(state_characteristics test_scores_gsdata feed_test_scores_gsdata feed_test_description_gsdata gsdata ratings district_largest)
end


def usage
  abort "\n\nUSAGE: rails runner script/populate_state_cache_table (all | [state]:[cache_keys])


Ex: rails runner script/populate_state_cache_table fl:state_characteristics
Ex: rails runner script/populate_state_cache_table all

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
  else
    args = []
    ARGV.each_with_index do |arg, i|
      state,cache_keys = arg.split(':')
      return false unless all_states.include?(state) || state == 'all'
      state = state == 'all' ? all_states : [state]
      cache_keys ||= 'none_given'
      cache_keys = cache_keys.split(',')
      cache_keys = all_cache_keys if cache_keys == ['all']
      cache_keys.each do |cache_key|
        return false unless all_cache_keys.include?(cache_key)
      end
      args[i] = {}
      args[i][:states] = state
      args[i][:cache_keys] = cache_keys
    end
    args
  end
end

parsed_arguments = parse_arguments

usage unless parsed_arguments.present?

parsed_arguments.each do |args|
  states = args[:states]
  cache_keys = args[:cache_keys]
  states.each do |state|
    puts
    puts "Working on: #{state}"
    cache_keys.each do |cache_key|
      puts "     doing #{cache_key}"
      StateCacher.create_cache(state, cache_key)
    end
  end
end

exit had_any_errors ? 1 : 0
