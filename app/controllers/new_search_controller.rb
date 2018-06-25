# frozen_string_literal: true

class NewSearchController < ApplicationController
  include Pagination::PaginatableRequest
  include SearchRequestParams

  layout 'application'
  before_filter :redirect_unless_valid_search_criteria # we need at least a 'q' param or state and city/district

  def search
    gon.search = {
      schools: serialized_schools,
    }.tap do |props|
      props['state'] = state
      if lat && lon
        props['lat'] = lat
        props['lon'] = lon
      end
      props.merge!(Api::CitySerializer.new(city_record).to_hash) if city_record
      props.merge!(Api::PaginationSummarySerializer.new(page_of_results).to_hash)
      props.merge!(Api::PaginationSerializer.new(page_of_results).to_hash)
    end

    prev_page = prev_page_url(page_of_results)
    next_page = next_page_url(page_of_results)
    set_meta_tags(prev: prev_page) if prev_page
    set_meta_tags(next: next_page) if next_page
    set_meta_tags(robots: 'noindex, nofollow') unless is_browse_url?
  end

  private

  # Paginatable
  def default_limit
    25
  end

  def redirect_unless_valid_search_criteria
    if q || (lat && lon)
      return
    elsif state && district
      unless district_record
        if city_record
          redirect_to city_path(city: city_param, state: state_param) && return
        else
          redirect_to(state_path(States.state_path(state))) && return
        end
      end
    elsif state && city
      redirect_to(state_path(States.state_path(state))) unless city_record
    elsif state
      redirect_to(state_path(States.state_path(state)))
    else
      redirect_to home_path
    end
  end

  def serialized_schools
    schools.map do |school|
      Api::SchoolSerializer.new(school).to_hash
    end
  end

  def schools
    @_schools ||= begin
      decorate_schools(page_of_results)
    end
  end

  def page_of_results
    @_page_of_results ||= query.search
  end

  def query
    solr_query
  end

  def school_sql_query
    Search::ActiveRecordSchoolQuery.new(
      state: state,
      id: params[:id],
      district_id: params[:district_id],
      entity_types: entity_types,
      city: city,
      lat: lat,
      lon: lon,
      radius: radius,
      level_codes: level_codes,
      sort_name: sort_name,
      offset: offset,
      limit: limit
    )
  end

  def attendance_zone_query
    ::Search::SchoolAttendanceZoneQuery.new(
      lat: lat,
      lon: lon,
      level: boundary_level,
      offset: offset,
      limit: limit
    )
  end

  def solr_query
    if params[:solr7]
      query_type = Search::SolrSchoolQuery
    else
      query_type = Search::LegacySolrSchoolQuery
    end

    query_type.new(
      city: city,
      state: state,
      level_codes: level_codes,
      entity_types: entity_types,
      lat: lat,
      lon: lon,
      radius: radius,
      q: q,
      offset: offset,
      limit: limit,
      sort_name: sort_name,
      district_id: district_record&.id
    )
  end

  def decorate_schools(schools)
    extras.each do |extra|
      method = "add_#{extra}"
      schools = send(method, schools) if respond_to?(method, true)
    end
    if cache_keys.any?
      schools = SchoolCacheQuery.decorate_schools(schools, *cache_keys)
    end
    schools
  end

  def cache_keys
    @_cache_keys ||= []
  end

  # methods for adding extras
  # method names prefixed with add_*
  def add_summary_rating(schools)
    cache_keys << 'ratings'
    schools
  end

  def add_distance(schools)
    return schools unless point_given? || area_given?

    schools.each do |school|
      if school.lat && school.lon
        distance = 
          Geo::Coordinate.new(school.lat, school.lon).distance_to(
            Geo::Coordinate.new(lat.to_f, lon.to_f)
          )
        school.define_singleton_method(:distance) do
          distance
        end
      end
    end

    schools
  end

  def extras
    ['summary_rating', 'distance']
  end

end