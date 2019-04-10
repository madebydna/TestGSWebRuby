class Api::NearbySchoolsController < ApplicationController
  include Pagination::PaginatableRequest
  include SearchRequestParams
  include SearchControllerConcerns
  include Api::Authorization
  
  CACHE_TIME = 12.hours

  before_filter :require_school, :require_authorization

  def show
    @array_of_nearby_school_hashes = serialized_schools
    expires_in(CACHE_TIME, public: true, must_revalidate: true)
    render 'api/nearby_schools/show'
  end

  def serialized_schools
    super.reject { |s| s[:id] == school.id }
  end

  protected 

  # Paginatable

  def default_limit
    6
  end

  def max_limit
    6
  end

  # SearchControllerConcerns

  def default_extras
    %w(summary_rating review_summary enrollment)
  end

  def not_default_extras
    []
  end

  def query
    query_type = Search::SolrSchoolQuery
    query_type.new(
      state: school.state,
      level_codes: school.level_codes,
      lat: lat,
      lon: lon,
      ratings: ratings,
      radius: 100,
      offset: offset,
      sort_name: 'distance',
      limit: 10
    )
  end

  # SearchRequestParams

  def lat
    school.lat
  end

  def lon
    school.lon
  end

  # Impl

  def school
    return @_school if defined?(@_school)
    @_school = School.find_by_state_and_id(params[:state], params[:id])
  end

  def require_school
    if school.blank? || !school.active?
      render json: {error: 'School not found'}, status: 404
    end
  end
end
