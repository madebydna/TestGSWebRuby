class UserFavoriteSchools

  def initialize(user)
    @user = user
  end

  def get
    favorite_schools = @user.favorite_schools
    school_to_fav_school = {}

    if favorite_schools.present?
      favorite_schools_map = favorite_schools.group_by { |s| "#{s.state.downcase}#{s.school_id}" }
      favorite_school_states = favorite_schools.map(&:state).map(&:downcase)
      favorite_school_ids = favorite_schools.map(&:school_id)
      my_school_list_schools = School.for_states_and_ids(favorite_school_states, favorite_school_ids)

      query = SchoolCacheQuery.new.include_cache_keys('ratings')
      my_school_list_schools.each do |school|
        query = query.include_schools(school.state, school.id)
      end
      query_results = query.query

      school_cache_results = SchoolCacheResults.new('ratings', query_results)
      my_school_list_schools = school_cache_results.decorate_schools(my_school_list_schools)


      my_school_list_schools.each do |s|
        school_to_fav_school[s] = favorite_schools_map["#{s.state.downcase}#{s.id}"].first
      end

    end
    school_to_fav_school
  end
end
