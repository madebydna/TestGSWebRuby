module SchoolProfiles
  class SchoolCacheDataReader
    # ratings - for gs rating
    # characteristics - for enrollment
    # reviews_snapshot - for review info in the profile hero
    SCHOOL_CACHE_KEYS = %w(ratings characteristics reviews_snapshot test_scores)

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

    def num_ratings
      decorated_school.num_ratings
    end

    def test_scores_rating
      decorated_school.test_scores_rating
    end

    def college_readiness_rating
      decorated_school.college_readiness_rating
    end

    def ethnicity_data
      decorated_school.ethnicity_data
    end

    def characteristics_data(*keys)
      decorated_school.characteristics.slice(*keys)
    end

    def subject_scores_by_latest_year(data_type_id:, breakdown: 'All', grades: 'All', level_codes: 'e,m,h')
      subject_hash = decorated_school.test_scores.seek(data_type_id.to_s, breakdown, 'grades', grades, 'level_code', level_codes)
      return OpenStruct.new unless subject_hash.present?
      subject_hash.inject([]) do |scores_array, (subject, year_hash)|
        scores_array << OpenStruct.new({}.tap do |scores_hash|
          latest_year = year_hash.keys.max_by { |year| year.to_i }
          scores_hash.merge!(year_hash[latest_year.to_s])
          scores_hash['subject'] = subject
          scores_hash['year'] = latest_year
        end)
      end
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
