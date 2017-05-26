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
        add_distance(s)
      end
    end
  end

  def require_state
    render json: { errors: ['State is required'] }, status: 404 if state.blank?
  end

  def schools
    @_schools ||= (
      if point_given?
        geometries = school_geometries_containing_lat_lon
        geometries_valid = geometries.present?
        if geometries && geometries.size > 1 && geometries[0].area == geometries[1].area
          # A geometry is not valid if it covers the same area as the next one
          # This is because we can't really recommend one of those boundaries above the other
          geometries_valid = false
        end
        items = geometries_valid ? SchoolGeometry.schools_for_geometries([geometries.first]) : []
      else
        items = get_schools
      end
      items = add_geometry(items)
      items = add_rating(items)
      items = add_review_summary(items)

      items
    )
  end

  def add_rating(schools)
    q = SchoolCacheQuery.new.
      include_objects(schools).
      include_cache_keys('ratings')

    school_cache_results = SchoolCacheResults.new('ratings', q.query_and_use_cache_keys)
    school_cache_results.decorate_schools(schools)
  end

  def add_geometry(schools)
    schools = Array.wrap(schools)
    if extras.include?('boundaries') && schools.length == 1
      schools = schools.map { |s| Api::SchoolWithGeometry.apply_geometry_data!(s) }
    end
    schools
  end

  def add_review_summary(schools)
    if extras.include?('review_summary') && schools.present?
      q = SchoolCacheQuery.new.
          include_objects(schools).
          include_cache_keys('reviews_snapshot')

      school_cache_results = SchoolCacheResults.new('reviews_snapshot', q.query_and_use_cache_keys)
      return school_cache_results.decorate_schools(schools)
    end
    schools
  end

  def add_distance(hash)
    if extras.include?('distance') && point_given? && hash.has_key?(:lat) && hash.has_key?(:lon)
      hash['distance'] = distance_between(hash[:lat], hash[:lon], lat.to_f, lon.to_f)
    end
    hash
  end

  def distance_between(lat1, lon1, lat2, lon2)
    rad_per_degree = Math::PI / 180
    radius_miles = 3959 # Earth radius
    lat1_rad = lat1 * rad_per_degree
    lat2_rad = lat2 * rad_per_degree
    lon1_rad = lon1 * rad_per_degree
    lon2_rad = lon2 * rad_per_degree

    a = Math.sin((lat2_rad - lat1_rad) / 2) ** 2 +
        Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin((lon2_rad - lon1_rad) / 2) ** 2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    (radius_miles * c).round(2) # Delta in miles
  rescue
    nil
  end

  def get_schools
    @_get_schools ||= (
      schools = School.on_db(state.to_s.downcase.to_sym).
        select("#{School.table_name}.*, #{District.table_name}.name as district_name").
        joins("LEFT JOIN district on school.district_id = district.id").
        where(criteria).
        active.
        limit(limit).
        offset(offset)

      if area_given?
        schools = schools.
          select("#{School.query_distance_function(lat,lon)} as distance").
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
