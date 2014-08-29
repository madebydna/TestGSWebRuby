def usage
  abort "USAGE: rails runner script/populate_school_cache_table (all|ratings|test_scores) [state] [school id].\n" +
    "If no state is provided, then as of r250 it does mi,in,wi,de,ca,nc,oh,dc."
end

usage unless ARGV[0] && ['all','ratings','test_scores', 'characteristics', 'esp_response'].include?(ARGV[0])

states = States.abbreviations
states_arg=ARGV[1]
school_ids_arg=ARGV[2]
cache_key_arg= ARGV[0]
all_cache_keys=['ratings','test_scores','characteristics', 'esp_response']

@@test_data_types = Hash[TestDataType.all.map { |f| [f.id, f] }]
@@test_descriptions = Hash[TestDescription.all.map { |f| [f.data_type_id.to_s+f.state, f] }]
@@proficiency_bands = Hash[TestProficiencyBand.all.map { |pb| [pb.id, pb] }]

def self.create_cache(school, cache_key)
  if (school.active?)
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

  if (results_obj_array.present?)
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

def self.esp_response_cache_for_school(school)
  esp_response_cacher = EspResponseCaching::EspResponseCacher.new(school)
  esp_response_cacher.cache
end

keys = []

if cache_key_arg.present? && cache_key_arg == 'all'
  keys = all_cache_keys
elsif cache_key_arg.present? && cache_key_arg != 'all'
  keys = all_cache_keys.select { |key| cache_key_arg.to_s.split(',').include?(key) }
end

keys.each do |cache_key|
  if !states_arg.nil? && !school_ids_arg.nil?
    school_ids_arg.to_s.split(',').each do | school_id_arg |
      school = School.on_db(states_arg.downcase.to_sym).find(school_id_arg)
      unless (school.nil?)
          create_cache(school, cache_key)
      end
    end
  elsif !states_arg.nil? && school_ids_arg.nil?
    states_arg.to_s.split(',').each do | state_arg |
      School.on_db(state_arg.downcase.to_sym).all.each do |school|
        create_cache(school, cache_key)
      end
    end
  else
    states.each do |state|
      School.on_db(state.downcase.to_sym).all.each do |school|
        create_cache(school, cache_key)
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
