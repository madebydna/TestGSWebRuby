# frozen_string_literal: true
# rubocop:disable Layout/EmptyLineAfterMagicComment, Layout/EmptyLinesAroundArguments


@had_any_errors = false

def all_cache_keys
  %w(header school_levels district_content)
end

def all_states
  States.abbreviations
end

def usage
  abort "\n\nUSAGE: rails runner script/populate_city_cache_table (all | [state] | blank:[cache_keys]:[city_ids])

Ex: rails runner script/populate_city_cache_table al:school_levels :all:8,9
Ex: rails runner script/populate_city_cache_table :header:5,6,7 de:all

Possible cache keys: #{all_cache_keys.join(', ')}\n\n"
end

def parse_arguments
  # Returns false or parsed arguments

  if ARGV[0] == 'all' && ARGV[1].nil?
    [{
         states: 'all',
         cache_keys: all_cache_keys
     }]
  else
    args = []
    ARGV.each_with_index do |arg, i|
      states,cache_keys,city_ids = arg.split(':')
      args[i] = {}
      args[i][:states] = handle_state(states)
      args[i][:cache_keys] = handle_cache_keys(cache_keys)
      args[i][:city_ids] = handle_city_ids(city_ids)
    end
    args
  end
end

def handle_state(states)
  st = states.split(',') if states.present?
  st.select{ |s| all_states.include?(s) }  if st.present? && st != ['all']
  { state: st } if st.present?
end

def handle_cache_keys(cache_keys)
  ck = cache_keys.split(',') if cache_keys.present?
  ck = all_cache_keys if ck == ['all'] || ck.blank?
  ck.select{ |cache_key| all_cache_keys.include?(cache_key) } if ck.present?
end

def handle_city_ids(city_ids)
  { id: city_ids.split(',') } if city_ids.present?
end

def process_city(city, cache_keys)
  cache_keys.each do |cache_key|
    begin
      CityCacher.create_cache(city, cache_key)
    # rescue => error
    #   @had_any_errors = true
    #   puts "City Error #{city.state}-#{city.name}-#{city.id}  #{error}"
    end
  end
end

parsed_arguments = parse_arguments

usage unless parsed_arguments.present?

# rubocop:disable Metrics/BlockLength

parsed_arguments.each do |args|
  states = args[:states]
  cache_keys = args[:cache_keys]
  city_ids = args[:city_ids]
  puts

  if states[:state] == ['all'] && city_ids.blank?
    puts "Working on all states - all cities"
    counter = 0
    City.get_all_cities.each do | city |
      process_city(city, cache_keys)
      counter += counter
      if counter%1000 == 0
        puts counter + " Cities complete"
      end
    end
  elsif states.blank? && city_ids.present?
    puts "Working on city_ids"
    City.where(city_ids).each do | city |
      process_city(city, cache_keys)
    end
  elsif states.present? && city_ids.blank?
    puts "Working on states with blank cities"
    City.where(states).each do | city |
     process_city(city, cache_keys)
    end
  else
    puts "Working on nothing"
  end
end
# rubocop:enable Metrics/BlockLength
# rubocop:enable Layout/EmptyLineAfterMagicComment, Layout/EmptyLinesAroundArguments
exit @had_any_errors ? 1 : 0
