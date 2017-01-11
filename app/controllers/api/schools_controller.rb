class Api::SchoolsController < ApplicationController
  include ApiPagination
  helper_method :next, :prev

  self.pagination_max_limit = 2000
  self.pagination_default_limit = 10
  # tell the mixed-in pagination methods what code it can evaluate
  # to determine how many results were found for the current request
  self.pagination_items_proc = proc { schools }

  before_action :require_state

  def index
    self.pagination_max_limit = 10 if criteria.blank?
    render json: {
      links: {
        prev: self.prev,
        next: self.next,
      },
      items: schools.map do |school|
        # Using a plain rubo object to convert domain object to json
        # decided not to use jbuilder. Dont feel like it adds benefit and
        # results in less flexible/resuable code. Could use
        # active_model_serializers (included with rails 5) but it's yet another
        # gem...
        Api::SchoolSerializer.new(school).to_hash.tap do |s|
          s.except(['geometry'] - extras)
        end
      end
    }
  end

  def require_state
    render json: { errors: ['State is required'] }, status: 404 if state.blank?
  end

  def schools
    @_schools ||= (
      if extras.include?('geometry') # see comment on "extras" method
        Api::SchoolWithGeometry.apply_geometry_data!(get_schools)
      else
        get_schools
      end
    )
  end

  def get_schools
    @_schools ||= School.on_db(state.to_s.downcase.to_sym).
      where(criteria).
      active.
      limit(limit).
      offset(offset).
      order(:id)
  end

  # criteria that will be used to query the school table
  def criteria
    c = params.slice(:district_id)
    if lat.present? && lon.present? && radius.blank?
      c['school_ids'] = school_geometry_containing_lat_lon.keys
    end
    c
  end

  def state
    params[:state]
  end

  def school_geometry_containing_lat_lon
    @_school_geometry_containing_lat_lon ||= (
      results = SchoolGeometry.select('school_id, AsText(geom) as geom').
        containing_point(lat,lon).
        order_by_area

      results.each_with_object({}) do |hash, result|
        hash[result['school_id']] = result['geom']
      end
    )
  end

  def lat
    params[:lat]
  end

  def lon
    params[:lon]
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
