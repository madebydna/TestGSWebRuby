# Populating a user's MSL with 2000 schools may cause cookie problems, so 
# if necessary, comment out `consistify_saved_schools(user) if user` in 
# `create`  in `signin_controller.rb` to test performance of other site 
# features with this number of schools.

TEST_USER = 7076901 # Account associated with 'achong@greatschools.org'
SAMPLE_STATES = ["al", "ca", "tx", "ut"]

SAMPLE_STATES.each do |state|
  puts state
  sample_state_schools = School.on_db(state.to_sym).active.limit(500)

  sample_state_schools.each do |school|
    FavoriteSchool.create_saved_school_instance(school, TEST_USER).save
  end
end 
