class Api::DistrictsController < ApplicationController
  include ApiPagination
  include Api::Authorization
  helper_method :next, :prev

  before_action :require_authorization

  self.pagination_max_limit = 2000
  self.pagination_default_limit = 10
  # tell the mixed-in pagination methods what code it can evaluate
  # to determine how many results were found for the current request
  self.pagination_items_proc = proc { districts }

  AVAILABLE_EXTRAS = %w[boundaries]

  before_action :require_state, unless: :location_given?

  def show
    hash = serialized_districts.first || {}
    render(json: hash)
  end

  def index
    self.pagination_max_limit = 10 if criteria.blank?
    render json: {
      links: {
        prev: self.prev,
        next: self.next,
      },
      items: serialized_districts
    }
  end

  def serialized_districts
    districts.map do |district|
      Api::DistrictSerializer.new(district).to_hash.tap do |d|
        d.except(AVAILABLE_EXTRAS - extras)
      end
    end
  end

  def require_state
    render json: { errors: ['State is required'] }, status: 404 if state.blank?
  end

  def districts
    @_districts ||= (
      items =
        if location_given?
          DistrictGeometry.districts_for_geometries(district_geometries_containing_lat_lon)
        else
          get_districts
        end
      items = add_geometry(items)
      items = add_rating(items)
    )
  end

  def add_rating(districts)
    q = DistrictCache.for_districts(districts)
          .include_cache_keys(['district_schools_summary'])

    school_cache_results = DistrictCacheResults.new(['district_schools_summary'], q)
    school_cache_results.decorate_districts(districts)
  end

  def add_geometry(districts)
    districts = Array.wrap(districts)
    if extras.include?('boundaries') && districts.length == 1
      districts = districts.map { |s| Api::DistrictWithGeometry.apply_geometry_data!(s) }
    end
    districts
  end


  def get_districts
    @_get_districts ||= (
      districts = District.on_db(state.to_s.downcase.to_sym).
        where(criteria).
        active.
        limit(limit).
        offset(offset)

      if lat.present? && lon.present? && radius.present?
        districts = districts.
          select("*, #{District.query_distance_function(lat,lon)} as distance").
          having("distance < #{radius}").
          order('distance asc')
      else
        districts = districts.order(:id)
      end
      districts
    )
  end

  def criteria
    params.slice(:id, :charter_only)
  end

  def state
    params[:state]
  end

  def district_geometries_containing_lat_lon
    @_district_geometries_containing_lat_lon ||= (
      DistrictGeometry.find_by_point_and_level(lat, lon, boundary_level)
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

  def location_given?
    lat.present? && lon.present? && radius.blank?
  end

  def boundary_level
    params[:boundary_level]
  end

  # reading about API design, I tend to agree that rather than make multiple
  # endpoints for different views on the same resource (district) we should allow
  # the client to say what data they want back. Felt like boundary data
  # belongs as part of the districts api resource, but it has performance
  # overhead to obtain that data and not every request needs it. Rather
  # than have the client provide every field desires, just made an "extras"
  # for asking for data not in the default response
  def extras
    (params[:extras] || '').split(',')
  end

end
