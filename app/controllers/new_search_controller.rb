# frozen_string_literal: true

class NewSearchController < ApplicationController
  layout 'application'

  def search
    @schools = schools
    @city = City.get_city_by_name_and_state(city, state).first
  end

  private

  def schools
    array = school_search.results
    array = hack_in_school_gs_rating(array)
    array.map { |s| Api::SchoolSerializer.new(s).to_hash }
  end

  def school_search
    @_school_search ||= SchoolSearch.new(city: city, state: state, q:q)
  end

  def city
    params[:city].try(:gsub, '-', ' ')
  end

  def state
    return nil unless params[:state].present?
    States.abbreviation(params[:state].gsub('-', ' '))
  end

  def q
    params[:q]
  end

  def hack_in_school_gs_rating(schools)
    query = SchoolCacheQuery.new.include_cache_keys(['ratings'])
    schools.each do |school|
      query = query.include_schools(school.state, school.id)
    end
    query_results = query.query
    school_cache_results = SchoolCacheResults.new(['ratings'], query_results)
    school_cache_results.decorate_schools(schools)
  end
end
