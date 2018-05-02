class Api::SchoolsController < ApplicationController
  include Pagination::PaginatableRequest

  AVAILABLE_EXTRAS = %w[boundaries]

  before_action :require_state, unless: :point_given?

  def show
    hash = serialized_schools.first || {}
    render(json: hash)
  end

  def index
    render json: {
      links: {
        prev: self.prev_offset_url(page_of_results),
        next: self.next_offset_url(page_of_results),
      },
      items: serialized_schools
    }.merge(Api::PaginationSummarySerializer.new(page_of_results).to_hash)
  end

  def serialized_schools
    # Using a plain rubo object to convert domain object to json
    # decided not to use jbuilder. Dont feel like it adds benefit and
    # results in less flexible/resuable code. Could use
    # active_model_serializers (included with rails 5) but it's yet another
    # gem...
    schools.map do |school|
      Api::SchoolSerializer.new(school).to_hash.tap do |s|
        s.except(AVAILABLE_EXTRAS - extras)
      end
    end
  end

  def require_state
    render json: { errors: ['State is required'] }, status: 404 if state.blank?
  end

  def schools
    @_schools ||= (
      decorate_schools(page_of_results)
    )
  end

  def page_of_results
    @_page_of_results ||= query.search
  end

  def query
    if q || sort_name == 'rating'
      solr_query
    elsif point_given?
      attendance_zone_query
    else
      school_sql_query
    end
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
    SchoolAttendanceZoneQuery.new(lat: lat, lon: lon, level: boundary_level)
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
      q: q,
      offset: offset,
      limit: limit,
      sort_name: sort_name
    )
  end

  def decorate_schools(schools)
    extras.each do |extra|
      method = "add_#{extra}"
      schools = send(method, schools) if respond_to?(method)
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

  def add_review_summary(schools)
    cache_keys << 'review_summary'
    schools
  end

  def add_boundaries(schools)
    schools = Array.wrap(schools)
    if schools.length == 1
      schools = schools.map { |s| Api::SchoolWithGeometry.apply_geometry_data!(s) }
    end
    schools
  end

  def add_distance(schools)
    return schools unless point_given?

    schools.each do |school|
      if school.lat && school.lon
        distance = 
          Geo::Point.new(hash[:lat], hash[:lon]).distance_to(
            Geo::Point.new(lat.to_f, lon.to_f)
          )
        school.define_singleton_method(:distance) do
          distance
        end
      end
    end

    schools
  end

  def state
    state_param = params[:state]
    return nil unless state_param.present?

    if States.is_abbreviation?(state_param)
      state_param
    else
      States.abbreviation(state_param.gsub('-', ' ').downcase)
    end
  end

  def school_geometries_containing_lat_lon
    @_school_geometries_containing_lat_lon ||= (
      SchoolGeometry.find_by_point_and_level(lat, lon, boundary_level)
    )
  end

  def q
    params[:q]
  end

  def lat
    params[:lat]
  end

  def lon
    params[:lon]
  end

  def radius
    params[:radius]
  end

  def entity_types
    params[:type]&.split(',')
  end

  def point_given?
    lat.present? && lon.present? && radius.blank?
  end

  def area_given?
    lat.present? && lon.present? && radius.present?
  end

  def level_codes
    params[:level_code]&.split(',')
  end

  def level_code
    level_codes&.first
  end

  def boundary_level
    (params[:boundary_level] || '').split(',').tap do |array|
      array << 'o' unless array.include?('o')
    end
  end

  def city_object
    @_city_object ||= City.get_city_by_name_and_state(city, state).first
  end

  def sort_name
    params[:sort]
  end

  def city
    params[:city]&.gsub('-', ' ')&.gs_capitalize_words
  end

  # reading about API design, I tend to agree that rather than make multiple
  # endpoints for different views on the same resource (school) we should allow
  # the client to say what data they want back. Felt like boundary data
  # belongs as part of the schools api resource, but it has performance
  # overhead to obtain that data and not every request needs it. Rather
  # than have the client provide every field desires, just made an "extras"
  # for asking for data not in the default response
  def extras
    (params[:extras] || '').split(',') + ['summary_rating']
  end

end
