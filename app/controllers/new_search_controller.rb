# frozen_string_literal: true

class NewSearchController < ApplicationController
  layout 'application'

  def search
    c = City.get_city_by_name_and_state(city, state).first
    props = OpenStruct.new.tap do |o|
      o.city = c.name
      o.state = state.upcase
      o.schools = schools
      o.lat = c.lat
      o.lon = c.lon
      o.total = school_search.total
      o.current_page = school_search.current_page
      o.offset = school_search.offset
      o.is_first_page = school_search.first_page?
      o.is_last_page = school_search.last_page?
      o.index_of_first_result = school_search.index_of_first_result
      o.index_of_last_result = school_search.index_of_last_result
      o.result_summary = school_search.result_summary
      o.pagination_summary = school_search.pagination_summary
    end
    gon.search = props.to_h
  end

  private

  def schools
    array = school_search.results
    array = hack_in_school_gs_rating(array)
    array.map { |s| Api::SchoolSerializer.new(s).to_hash }
  end

  def school_search
    @_school_search ||= SchoolSearch.new(city: city, state: state, q:q, page: page)
  end

  def city
    params[:city].try(:gsub, '-', ' ').gs_capitalize_words
  end

  def state
    return nil unless params[:state].present?
    States.abbreviation(params[:state].gsub('-', ' '))
  end

  def q
    params[:q]
  end

  def page
    params[:page] || 1
  end

  def hack_in_school_gs_rating(schools)
    query = SchoolCacheQuery.new.include_cache_keys(['ratings', 'characteristics'])
    schools.each do |school|
      query = query.include_schools(school.state, school.id)
    end
    query_results = query.query
    school_cache_results = SchoolCacheResults.new(['ratings', 'characteristics'], query_results)
    school_cache_results.decorate_schools(schools)
  end
end
