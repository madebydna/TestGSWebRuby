module SchoolProfiles
  class SchoolCacheDataReader
    # ratings - for gs rating
    # characteristics - for enrollment
    # reviews_snapshot - for review info in the profile hero
    SCHOOL_CACHE_KEYS = %w(ratings characteristics reviews_snapshot)

    attr_reader :school, :school_cache_keys

    def initialize(school, school_cache_keys: SCHOOL_CACHE_KEYS)
      self.school = school
      @school_cache_keys = school_cache_keys
    end

    def decorated_school
      @_decorated_school ||= decorate_school(school)
    end

    def gs_rating
      decorated_school.great_schools_rating
    end

    def students_enrolled
      decorated_school.students_enrolled
    end

    def five_star_rating
      decorated_school.star_rating
    end

    def number_of_active_reviews
      decorated_school.num_reviews
    end

    def test_scores_rating
      decorated_school.test_scores_rating
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
