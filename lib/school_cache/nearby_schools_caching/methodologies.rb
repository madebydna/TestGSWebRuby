class NearbySchoolsCaching::Methodologies
  class << self
    def results(school, opts)
      schools = schools(school, opts)
      NearbySchoolsCaching::QueryResultDecorator.decorate_list(schools).map(&:to_h)
    end

    protected

    def schools(*args)
      raise NotImplementedError, 'All NearbySchoolsCaching::Methodologies must
                                  implement #school and it must return an array
                                  of School objects.'
    end

    def basic_nearby_schools_fields
      'school.id,
       school.street,
       school.city,
       school.state,
       school.name,
       school.level,
       school.type,
       school.level_code'
    end

    def basic_nearby_schools_conditions(school)
      "school.active = 1 AND
       school.id != #{school.id} AND
       school.lat is not null AND
       school.lon is not null
       #{level_code_filter(school)}"
    end

    # The Haversine formula: https://en.wikipedia.org/wiki/Haversine_formula
    def distance_from_school(school)
      miles_center_of_earth = 3959
      "(
      #{miles_center_of_earth} *
       acos(
         cos(radians(#{school.lat})) *
         cos( radians( `lat` ) ) *
         cos(radians(`lon`) - radians(#{school.lon})) +
         sin(radians(#{school.lat})) *
         sin( radians(`lat`) )
       )
     )"
    end

    # The level_code filtering works for single-level_code and multi-level_code
    # schools alike: a high school will return high schools, an
    # elementary-middle school will return elementary, middle, or
    # elementary-middle schools.
    def level_code_filter(school)
      return '' if school.level_code_array.blank?
      arr_query_str = []
      school.level_code_array.each do |one_level_code|
        arr_query_str << "school.level_code LIKE '%#{one_level_code}%'"
      end
      arr_query_str.present? ? 'AND (' << arr_query_str.join(" || ") << ')' : ''
    end
  end
end
