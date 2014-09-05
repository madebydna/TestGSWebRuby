def all_cache_keys
  ['ratings','test_scores','characteristics', 'esp_responses', 'reviews_snapshot']
end

def nightly_states
  ['de']
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
  if ARGV[0] == 'all'
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


def self.create_cache(school, cache_key)
  if school.active?
    begin
      action = "#{cache_key}_cache_for_school"
      self.send action, school
    rescue => error
      Rails.logger.error "ERROR: populating school cache for school id: #{school.id} in state: #{school.state}." +
                             "\nException : #{error.message}."
    end
  else
    Rails.logger.error "ERROR: populating school cache for school id: #{school.id} in state: #{school.state}." +
                           "\nSchool is inactive."
  end
end

# Uses configuration_map to map attributes/methods in obj_array to keys in a hash
def self.map_object_array_to_hash_array(configuration_map, obj_array)
  rval = []
  obj_array.each do |obj|
    rval << active_record_to_hash(configuration_map, obj)
  end
  rval
end

def self.active_record_to_hash(configuration_map, obj)
  rval_map = {}
  configuration_map.each do |key, val|
    if obj.attributes.include?(key.to_s)
      rval_map[val] = obj[key]
    elsif obj.respond_to?(key)
      rval_map[val] = obj.send(key)
    else
      Rails.logger.error "ERROR: Can't find attribute or method named #{key} in #{obj}"
    end
  end
  rval_map
end

def self.test_description_for(data_type_id,state)
  @@test_descriptions["#{data_type_id}#{state}"]
end


def self.ratings_cache_for_school(school)
  results_obj_array = TestDataSet.ratings_for_school(school)
  school_cache = SchoolCache.find_or_initialize_by(school_id: school.id,state: school.state,name: 'ratings')

  if results_obj_array.present?
    config_map = {
      :data_type_id => 'data_type_id',
      :year => 'year',
      :school_value_text => 'school_value_text',
      :school_value_float => 'school_value_float'
    }
    results_hash_array = map_object_array_to_hash_array(config_map, results_obj_array)
    # Prune out empty data sets
    results_hash_array.delete_if {|hash| hash['school_value_text'].nil? && hash['school_value_float'].nil?}
    school_cache.update_attributes!(:value => results_hash_array.to_json, :updated => Time.now)
  elsif school_cache && school_cache.id.present?
    SchoolCache.destroy(school_cache.id)
  end
end


def self.test_scores_cache_for_school(school)
  test_scores_cacher = TestScoresCaching::BreakdownsCacher.new(school)
  test_scores_cacher.cache
end

def self.characteristics_cache_for_school(school)
  characteristics_cacher = CharacteristicsCaching::CharacteristicsCacher.new(school)
  characteristics_cacher.cache
end

def self.esp_responses_cache_for_school(school)
  esp_response_cacher = EspResponsesCaching::EspResponsesCacher.new(school)
  esp_response_cacher.cache
end

def self.reviews_snapshot_cache_for_school(school)
  esp_response_cacher = ReviewsCaching::ReviewsSnapshotCacher.new(school)
  esp_response_cacher.cache
end

parsed_arguments.each do |args|
  states = args[:states]
  cache_keys = args[:cache_keys]
  school_ids = args[:school_ids]
  states.each do |state|
    next if ARGV[0] == 'all' && !nightly_states.include?(state)
    cache_keys.each do |cache_key|
      if school_ids
        School.on_db(state.downcase.to_sym).where(id: school_ids).each do |school|
          create_cache(school, cache_key)
        end
      else
        School.on_db(state.downcase.to_sym).all.each do |school|
          create_cache(school, cache_key)
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
