class Api::SchoolsController < ApplicationController
  include ApiPagination
  helper_method :next, :prev

  self.pagination_max_limit = 2000
  self.pagination_default_limit = 10
  # tell the mixed-in pagination methods what code it can evaluate
  # to determine how many results were found for the current request
  self.pagination_items_proc = proc { schools }

  AVAILABLE_EXTRAS = %w[boundaries]

  before_action :require_state, unless: :point_given?

  def show
    hash = serialized_schools.first || {}
    render(json: hash)
  end

  def index
    self.pagination_max_limit = 10 if criteria.blank?
    render json: {
      links: {
        prev: self.prev,
        next: self.next,
      },
      items: serialized_schools
    }
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
      items = if point_given?
        SchoolGeometry.schools_for_geometries(school_geometries_containing_lat_lon).first
      else
        get_schools
      end
      items = add_geometry(items)
      items = add_rating(items)
    )
  end

  def add_rating(schools)
    q = SchoolCacheQuery.new.
      include_objects(schools).
      include_cache_keys('ratings')

    school_cache_results = SchoolCacheResults.new('ratings', q.query)
    school_cache_results.decorate_schools(schools)
  end

  def add_geometry(schools)
    schools = Array.wrap(schools)
    if extras.include?('boundaries') && schools.length == 1
      schools = schools.map { |s| Api::SchoolWithGeometry.apply_geometry_data!(s) }
    end
    schools
  end

  def get_schools
    @_get_schools ||= (
      schools = School.on_db(state.to_s.downcase.to_sym).
        where(criteria).
        active.
        limit(limit).
        offset(offset)

      if area_given?
        schools = schools.
          select("*, #{School.query_distance_function(lat,lon)} as distance").
          having("distance < #{radius}").
          order('distance asc')
      else
        schools = schools.order(:id)
      end

      if level_code
        schools = schools.where('level_code LIKE ?', "%#{level_code}%")
      end
      schools
    )
  end

  # criteria that will be used to query the school table
  def criteria
    params.slice(:id, :district_id, :type)
  end

  def state
    params[:state]
  end

  def school_geometries_containing_lat_lon
    @_school_geometries_containing_lat_lon ||= (
      SchoolGeometry.find_by_point_and_level(lat, lon, boundary_level)
    )
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

  def type
    params[:type]
  end

  def point_given?
    lat.present? && lon.present? && radius.blank?
  end

  def area_given?
    lat.present? && lon.present? && radius.present?
  end

  def level_code
    params[:level_code]
  end

  def boundary_level
    (params[:boundary_level] || '').split(',').tap do |array|
      array << 'o' unless array.include?('o')
    end
  end

  # reading about API design, I tend to agree that rather than make multiple
  # endpoints for different views on the same resource (school) we should allow
  # the client to say what data they want back. Felt like boundary data
  # belongs as part of the schools api resource, but it has performance
  # overhead to obtain that data and not every request needs it. Rather
  # than have the client provide every field desires, just made an "extras"
  # for asking for data not in the default response
  def extras
    (params[:extras] || '').split(',')
  end

end