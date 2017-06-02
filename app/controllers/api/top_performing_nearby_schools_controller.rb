class Api::TopPerformingNearbySchoolsController < ApplicationController
  DEFAULT_LIMIT = 6
  MAX_LIMIT = 6

  before_filter :require_school

  def show
    array_of_nearby_school_hashes = []
    results = SchoolSearchService.by_location(school_search_service_params)
    array_of_nearby_school_hashes = results[:results].take(limit)
    array_of_nearby_school_hashes.map! do |ssr|
      ssr = SchoolSearchResultDecorator.decorate(ssr)
      {
        'state' => ssr.state.upcase,
        'id' => ssr.id,
        'name' => ssr.name,
        'city' => ssr.city,
        'type' => ssr.decorated_school_type,
        'level' => ssr.grade_range,
        'gs_rating' => ssr.overall_gs_rating,
        'average_rating' => ssr.community_rating,
        'number_of_reviews' => ssr.review_count,
        'distance' => ssr.distance
      }
    end
    @array_of_nearby_school_hashes = array_of_nearby_school_hashes
    render 'api/nearby_schools/show'
  end

  protected 

  def school_search_service_params
    {
      number_of_results: limit,
      offset: offset + 1, # closest school is the same school
      sort: :distance_asc,
      lat: school.lat,
      lon: school.lon,
      radius: 100,
      state: school.state,
      filters: {
        overall_gs_rating: [8,9,10],
        level_code: school.level_code.split(',').map do |code|
          {
            'p' => :preschool,
            'e' => :elementary,
            'm' => :middle,
            'h' => :high
          }[code]
        end
      }
    }
  end

  def limit
    return DEFAULT_LIMIT unless params[:limit]
    [params[:limit].to_i, MAX_LIMIT].min
  end

  def school
    return @_school if defined?(@_school)
    @_school = School.find_by_state_and_id(params[:state], params[:id])
  end

  def require_school
    if school.blank? || !school.active?
      render json: {error: 'School not found'}, status: 404
    end
  end

  def offset
    params[:offset].to_i
  end

  class SchoolCacheDataReader
    SCHOOL_CACHE_KEYS = %w(nearby_schools)

    attr_reader :school, :school_cache_keys

    def initialize(school, school_cache_keys: SCHOOL_CACHE_KEYS)
      self.school = school
      @school_cache_keys = school_cache_keys
    end

    def decorated_school
      @_decorated_school ||= decorate_school(school)
    end

    def nearby_schools
      decorated_school.nearby_schools
    end

    def school_cache_query
      SchoolCacheQuery.for_school(school).tap do |query|
        query.include_cache_keys(school_cache_keys)
      end
    end

    def decorate_school(school)
      query_results = school_cache_query.query
      school_cache_results = SchoolCacheResults.new(SCHOOL_CACHE_KEYS, query_results)
      school_cache_results.decorate_school(school)
    end

    private

    def school=(school)
      raise ArgumentError('School must be provided') if school.nil?
      @school = school
    end
  end

end
