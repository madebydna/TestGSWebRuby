states = ['mi', 'in', 'wi', 'de']
states_arg=ARGV[0]
school_ids_arg=ARGV[1]
cache_key_arg= ARGV[2]
all_cache_keys=['ratings']

def self.create_cache(school, cache_key)
  if (school.active?)
    begin
      action = "#{cache_key}_cache_for_school"
      self.send action, school
    rescue => error
      Rails.logger.debug "ERROR: populating school cache for school id: #{school.id} in state: #{school.state}" +
                             "Exception message: #{error.message}"
    end
  else
    Rails.logger.debug "ERROR: populating school cache for school id: #{school.id} in state: #{school.state}" +
                           "School is inactive"
  end
end

def self.ratings_cache_for_school(school)
  results = TestDataSet.ratings_for_school(school)
  school_cache = SchoolCache.find_or_initialize_by_school_id_and_state_and_name(school.id,school.state,'ratings')

  if !(results.blank?)
    cache_value = results.to_json(:except => [:proficiency_band_id, :school_decile_tops], :methods => [:school_value_text, :school_value_float])
    #Dont like the long initialize_by method name, but we are on rails 3. rails  4 does this more elegantly.
    school_cache.update_attributes!(:value => cache_value, :updated => Time.now)
  elsif !(school_cache.nil?)
    SchoolCache.destroy(school_cache.id)
  end
end

keys = all_cache_keys

if !cache_key_arg.nil?
  keys.select! { |key| cache_key_arg.to_s.split(',').include?(key) }
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
