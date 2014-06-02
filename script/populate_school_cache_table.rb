states = ['mi', 'in', 'wi', 'de','ca','nc','oh']
states_arg=ARGV[1]
school_ids_arg=ARGV[2]
cache_key_arg= ARGV[0]
all_cache_keys=['ratings','test_scores']

@@test_data_types = Hash[TestDataType.all.map { |f| [f.id, f] }]
@@test_descriptions = Hash[TestDescription.all.map { |f| [f.data_type_id.to_s+f.state, f] }]

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
  results_hash_array = []

  data_sets_and_values = TestDataSet.fetch_test_scores(school, 1, 1)

  if data_sets_and_values.present?
    config_map = {
      :data_type_id => 'data_type_id',
      :data_set_id => 'data_set_id',
      :level_code => 'level_code',
      :subject_id => 'subject_id',
      :grade => 'grade',
      :year => 'year',
      :school_value_text => 'school_value_text',
      :school_value_float => 'school_value_float',
      :state_value_text => 'state_value_text',
      :state_value_float => 'state_value_float',
      :breakdown_id => 'breakdown_id',
      :number_tested => 'number_tested'
    }

    data_type_ids = []
    data_sets_and_values.each do |data_sets_and_value|
      data_type_id = data_sets_and_value.data_type_id
      next if !@@test_data_types || @@test_data_types[data_type_id].nil? # skip this if no corresponding test data type
      data_type_ids << data_type_id
      results_hash_array << active_record_to_hash(config_map,data_sets_and_value)
    end

    data_type_descriptions = {}
    data_type_ids.each do |data_type_id|
      description_hash = {'test_label' => @@test_data_types[data_type_id].display_name}
      test_description = test_description_for(data_type_id,school.state)
      if !test_description.nil?
        description_hash['test_description'] = test_description.description
        description_hash['test_source'] = test_description.source
      end
      data_type_descriptions[data_type_id] = description_hash
    end

    school_cache = SchoolCache.find_or_initialize_by(school_id: school.id,state: school.state,name:'test_scores')
    if results_hash_array.present?
      final_hash = {'data_sets_and_values' => results_hash_array, 'data_types' => data_type_descriptions}
      school_cache.update_attributes!(:value => final_hash.to_json, :updated => Time.now)
    elsif school_cache && school_cache.id.present?
      SchoolCache.destroy(school_cache.id)
    end

  end

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
