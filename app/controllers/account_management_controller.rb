class AccountManagementController < ApplicationController
  protect_from_forgery

  layout 'application'

  before_action :login_required

  def show
    favorite_schools = @current_user.favorite_schools
    if favorite_schools.present?
      favorite_school_states = favorite_schools.map(&:state).map(&:downcase)
      favorite_school_ids = favorite_schools.map(&:school_id)
      my_school_list_schools = School.for_states_and_ids(favorite_school_states, favorite_school_ids)
      query_results = SchoolCacheQuery.new.
        include_cache_keys('ratings').
        include_schools('ca', my_school_list_schools.map(&:id)).
        query
      school_cache_results = SchoolCacheResults.new('ratings', query_results)
      @my_school_list_schools = school_cache_results.decorate_schools(my_school_list_schools)
    end
  end


end