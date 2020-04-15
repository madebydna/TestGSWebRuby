# frozen_string_literal: true

module HeaderCaching
  class CityHeaderCacher < CityCacher

    CACHE_KEY = 'header'
    SCHOOL_CACHE_KEYS = ['metrics']

    def self.listens_to?(data_type)
      data_type == :header
    end

    def header_keys
      %w(enrollment school_count)
    end

    def build_hash_for_cache
      header_keys.each_with_object({}) do |key, hash|
        if key == 'enrollment'
          hash[key] = [{ city_value: enrollment }]
        elsif key == 'school_count'
          hash[key] = [{ city_value: number_of_schools }]
        end
      end
    end

    def enrollment
      city_schools = city.schools_within_city
      query = SchoolCacheQuery.new.include_cache_keys(SCHOOL_CACHE_KEYS).include_schools(city.state, city_schools.map(&:id))
      query_results = query.query_and_use_cache_keys
      school_cache_results = SchoolCacheResults.new(SCHOOL_CACHE_KEYS, query_results)
      decorated_schools = school_cache_results.decorate_schools(city_schools)
      decorated_schools.reduce(0) { |sum, school| sum + school.students_enrolled.to_i }


      # city.schools_within_city.reduce(0) { |sum, school|
      #   e = decorate_school(school).students_enrolled
      #   sum + e.to_i
      # }
    end

    # def school_cache_query(school)
    #   SchoolCacheQuery.for_school(school).tap do |query|
    #     query.include_cache_keys(SCHOOL_CACHE_KEYS)
    #   end
    # end
    #
    # def decorate_school(school)
    #   query_results = school_cache_query(school).query
    #   school_cache_results = SchoolCacheResults.new(SCHOOL_CACHE_KEYS, query_results)
    #   school_cache_results.decorate_school(school)
    # end

    def number_of_schools
      city.schools_within_city.count
    end

  end
end