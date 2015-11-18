class AccountManagementController < ApplicationController
  protect_from_forgery

  layout 'application'

  before_action :login_required

  def show
    @page_name = 'Account management'
    gon.pagename = 'Account management'
    gon.omniture_pagename = 'GS:Admin:MyAccount'
    # User might not have a user_profile row in the db. It might be nil
    state_locale = @current_user.user_profile.try(:state)
    if state_locale.present?
      @state_locale = {
          long: States.state_name(state_locale.downcase.gsub(/\-/, ' ')),
          short: States.abbreviation(state_locale.downcase.gsub(/\-/, ' '))
      }
      gon.state_locale_abbr = States.abbreviation(state_locale.downcase.gsub(/\-/, ' '))
    end
    # User might not have a user_profile row in the db. It might be nil
    @city_locale  = @current_user.user_profile.try(:city)

    favorite_schools = @current_user.favorite_schools
    favorite_schools_map = favorite_schools.group_by { |s| "#{s.state.downcase}#{s.school_id}"}

    if favorite_schools.present?
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

      @school_to_favorite_school = {}
      my_school_list_schools.each do |s|
        @school_to_favorite_school[s] = favorite_schools_map["#{s.state.downcase}#{s.id}"].first
      end
      @school_to_favorite_school
    end
    account_meta_tags
    set_saved_searches_instance_variables
    @reviews =  current_user.reviews
    @display_grade_level_array = ['PK','KG', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12']
    @selected_grade_level = @current_user.student_grade_levels
  end

  def account_meta_tags
    set_meta_tags :title => "My account | GreatSchools",
                :robots => "noindex"
  end

  def reset_password
    
  end

  protected

  def set_saved_searches_instance_variables
    @saved_searches = current_user.saved_searches.limit(50).all
  end


end