class Api::TopPerformingNearbySchoolsController < ApplicationController
  DEFAULT_LIMIT = 4
  MAX_LIMIT = 4

  before_filter :require_school

  def show
    nearby_school_cache_hash =
      SchoolCacheDataReader.new(school).nearby_schools
    array_of_nearby_school_hashes = []

    if nearby_school_cache_hash.present?
      array_of_nearby_school_hashes =
        nearby_school_cache_hash['closest_top_then_top_nearby_schools'] || []
      array_of_nearby_school_hashes = array_of_nearby_school_hashes.take(limit)
    end

    @array_of_nearby_school_hashes = array_of_nearby_school_hashes
    render 'api/nearby_schools/show'
  end

  protected 

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
