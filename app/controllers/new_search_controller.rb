# frozen_string_literal: true

class NewSearchController < ApplicationController
  include Pagination::PaginatableRequest
  include SearchRequestParams
  include AdvertisingConcerns
  include PageAnalytics

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
      props[:district] = district_record.name if district_record
      props.merge!(Api::PaginationSummarySerializer.new(page_of_results).to_hash)
      props.merge!(Api::PaginationSerializer.new(page_of_results).to_hash)
      props[:breadcrumbs] = search_breadcrumbs
    end

    prev_page = prev_page_url(page_of_results)
    next_page = next_page_url(page_of_results)
    set_meta_tags(prev: prev_page) if prev_page
    set_meta_tags(next: next_page) if next_page
    set_meta_tags(robots: 'noindex, nofollow') unless is_browse_url?
    set_ad_targeting_props
    set_page_analytics_data
  end

  private

  def search_breadcrumbs
    @_search_breadcrumbs ||=
      [
        { 
          text: StructuredMarkup.state_breadcrumb_text(state),
          url: state_url(state_params(state))
        },
        {
          text: StructuredMarkup.city_breadcrumb_text(state: state, city: city),
          url: city_url(city_params(state, city))
        }
      ]
  end

  # StructuredMarkup
  def prepare_json_ld
    search_breadcrumbs.each { |bc| add_json_ld_breadcrumb(bc) }
  end

  # AdvertisingConcerns
  def ad_targeting_props
    {
      page_name: "GS:SchoolS",
      template: "search",
    }.tap do |hash|
      hash[:district_id] = district_id if district_id
      hash[:school_id] = school_id if school_id
      # these intentionally capitalized to match property names that have
      # existed for a long time. Not sure if it matters
      hash[:City] = city.gs_capitalize_words if city
      hash[:State] = state if state
      hash[:level] = level_codes.map { |s| s[0] } if level_codes.present?
      hash[:type] = entity_types.map(&:capitalize) if entity_types.present?
      hash[:county] = county_object&.name if county_object
      # hash[:zipcode]
    end
  end

  def page_analytics_data
    {}.tap do |hash|
      hash[PageAnalytics::SEARCH_TERM] = q if q
      hash[PageAnalytics::SEARCH_TYPE] = search_type
      hash[PageAnalytics::SEARCH_HAS_RESULTS] = page_of_results.any?
    end
  end

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
      district_id: district_record&.id,
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

  def add_enrollment(schools)
    cache_keys << 'characteristics'
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

  def add_assigned(schools)
    assigned_schools = location_given? ? attendance_zone_query.search_all_levels : []
    schools.each do | sr |
      assigned_schools.each do | as |
        sr.assigned ||= sr&.id == as&.id
      end
    end

    schools
  end

  def extras
    %w(summary_rating distance assigned enrollment)
  end

end
