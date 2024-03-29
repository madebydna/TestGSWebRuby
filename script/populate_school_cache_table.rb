had_any_errors = false

def all_cache_keys
  %w(ratings characteristics esp_responses reviews_snapshot nearby_schools gsdata feed_characteristics directory courses test_scores_gsdata feed_test_scores_gsdata feed_old_test_scores_gsdata)
end

def usage
  abort "\n\nUSAGE: rails runner script/populate_school_cache_table (all | [state]:[cache_keys]:[school_where])

Ex: rails runner script/populate_school_cache_table al:test_scores_gsdata de:all:9,18,23
Ex: rails runner script/populate_school_cache_table al:test_scores_gsdata de:all:\"id IN (9,18,23) or level_code like '%h%'\"

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
      state,cache_keys,schools_where = arg.split(':')
      return false unless all_states.include?(state) || state == 'all'
      state = state == 'all' ? all_states : [state]
      cache_keys ||= 'none_given'
      cache_keys = cache_keys.split(',')
      cache_keys = all_cache_keys if cache_keys == ['all']
      cache_keys.each do |cache_key|
        return false unless all_cache_keys.include?(cache_key)
      end
      if schools_where
        if !schools_where.include?(' ')
          schools_where = { id: schools_where.split(',') }
        end
      end
      args[i] = {}
      args[i][:states] = state
      args[i][:cache_keys] = cache_keys
      args[i][:schools_where] = schools_where if schools_where.present?
    end
    args
  end
end

parsed_arguments = parse_arguments

usage unless parsed_arguments.present?

parsed_arguments.each do |args|
  states = args[:states]
  cache_keys = args[:cache_keys]
  schools_where = args[:schools_where]
  states.each do |state|
    puts "Working on: #{state}"
    cache_keys.each do |cache_key|
      retries = 0
      puts "     doing #{cache_key}"
      if schools_where
        School.on_db(state.downcase.to_sym).where(schools_where).each do |school|
          # begin
            Cacher.create_cache(school, cache_key)
          # rescue => error
          #   puts "School #{school.state}-#{school.id} : #{error}"
          #   if error.try(:original_exception)&.class == Mysql2::Error && retries < 2
          #     puts "Mysql2 error. Reloading connections"
          #     sleep 10.seconds
          #     ActiveRecord::Base.connection_handler.clear_reloadable_connections!
          #     retries += 1
          #     retry
          #   end
          #   had_any_errors = true
          # end
        end
      else
        School.on_db(state.downcase.to_sym).all.each do |school|
          begin
            Cacher.create_cache(school, cache_key)
          rescue => error
            puts "School #{school.state}-#{school.id} : #{error}"
            if error.try(:original_exception)&.class == Mysql2::Error && retries < 2
              puts "Mysql2 error. Reloading connections"
              sleep 10.seconds
              ActiveRecord::Base.connection_handler.clear_reloadable_connections!
              retries += 1
              retry
            end
            had_any_errors = true
          end
        end
      end
    end
  end
end

exit had_any_errors ? 1 : 0
