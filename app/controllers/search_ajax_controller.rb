class SearchAjaxController < ApplicationController
  include States
  protect_from_forgery

  layout false

  SCHOOL_CACHE_KEYS = %w(esp_responses)

  def calculate_school_fit
    return unless session[:soft_filter_params] && session[:soft_filter_params].size > 0
    state = get_state
    city = get_city
    id = get_id
    unless state.nil? || id.nil?
      school = School.find_by_state_and_id(state, id)
      if school.active?
        school = decorate_school school
        @school = calculate_fit_score(school, state, city)
      end
    end
  end

  protected

  def get_state
    state_str_dirty = params[:state] || ''
    state_str = state_str_dirty.downcase
    States.abbreviations.include?(state_str) ? state_str.to_sym : nil
  end

  def get_city
    city_str = params[:city]
    !city_str.nil? ? city_str.downcase : nil
  end

  def get_id
    id = Integer params[:id] rescue 0
    (!id.nil? && id > 0) ? id : nil
  end

  def decorate_school(school)
    query = SchoolCacheQuery.new.include_cache_keys(SCHOOL_CACHE_KEYS)
    query = query.include_schools(school.state, school.id)
    query_results = query.query

    school_cache_results = SchoolCacheResults.new(SCHOOL_CACHE_KEYS, query_results)
    school_cache_results.decorate_schools([school]).first
  end

  def calculate_fit_score(school, state='', city='')
    school.send(:extend, FitScoreConcerns)
    filter_display_map = FilterBuilder.new(state, city).filter_display_map # for labeling fit score breakdowns
    decorated_school = SchoolCompareDecorator.decorate(school)
    decorated_school.calculate_fit_score!(session[:soft_filter_params] || {})
    unless decorated_school.fit_score_breakdown.nil?
      decorated_school.update_breakdown_labels! filter_display_map
      decorated_school.sort_breakdown_by_match_status!
    end
    decorated_school
  end
end