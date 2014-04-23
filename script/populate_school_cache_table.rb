states = ['mi', 'in', 'wi', 'de']
state_arg=ARGV[0]
school_id_arg=ARGV[1]
cache_key_arg= ARGV[2]
all_cache_keys=['ratings']

def self.create_cache(school, cache_key)
  begin
    action = "#{cache_key}_cache_for_school"
    self.send action, school
  rescue => error
    Rails.logger.debug "ERROR: populating school cache for school id: #{school.id} in state: #{school.state}" +
                           "Exception message: #{error.message}"
  end
end

def self.ratings_cache_for_school(school)
  results = TestDataSet.ratings_for_school(school)
  unless (results.nil?)
    SchoolCache.create(school_id: school.id, name: "ratings", state: school.state, value: results.to_json(:except => [:proficiency_band_id, :school_decile_tops], :methods => [:school_value_text, :school_value_float]))
  end
end

keys = all_cache_keys

if !cache_key_arg.nil?
  keys.select! { |key| cache_key_arg.to_s.split(',').include?(key) }
end

keys.each do |cache_key|
  if !state_arg.nil? && !school_id_arg.nil?
    school = School.on_db(state_arg.downcase.to_sym).find(school_id_arg)
    unless (school.nil?)
      Array(school).each do |school|
        create_cache(school, cache_key)
      end
    end
  elsif !state_arg.nil? && school_id_arg.nil?
    School.on_db(state_arg.downcase.to_sym).all.each do |school|
      create_cache(school, cache_key)
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
