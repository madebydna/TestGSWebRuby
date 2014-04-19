states = ['mi', 'in', 'wi', 'de']
state_arg=ARGV[0]
school_id_arg=ARGV[1]
cache_key= ARGV[2]

#TODO
#1)use cache_key.Maybe refactor into modules for seperate cache_keys.Also have a enum for keys?
#2)use logs for debugs in rescue statement
#3)rescue not unique error?

def self.ratings_cache_for_school(school)
  results = TestDataSet.ratings_for_school(school)
  unless (results.nil?)
    SchoolCache.create(school_id: school.id, name: "ratings_profile", state: school.state, value: results.to_json(:except => [:proficiency_band_id, :school_decile_tops], :methods => [:school_value_text, :school_value_float]))
  end
end

if !state_arg.nil? && !school_id_arg.nil?
  school = School.on_db(state_arg.downcase.to_sym).find(school_id_arg)
  unless (school.nil?)
    ratings_cache_for_school(school)
  end
elsif !state_arg.nil? && school_id_arg.nil?
  School.on_db(state_arg.downcase.to_sym).all.each do |school|
    begin
      ratings_cache_for_school(school)
    rescue
      next
    end
  end
else
  states.each do |state|
    School.on_db(state.downcase.to_sym).all.each do |school|
      ratings_cache_for_school(school)
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
