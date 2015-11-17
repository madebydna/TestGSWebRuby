class NearbySchoolsCaching::Lists::ClosestSchools < NearbySchoolsCaching::Lists
  NAME = 'closest_schools'.freeze

  class << self

    # The closest schools that serve similar grade levels. The list is returned
    # in distance order, smallest to largest.
    #
    # The level_code filtering works for single-level_code and multi-level_code
    # schools alike: a high school will return high schools, an
    # elementary-middle school will return elementary, middle, or
    # elementary-middle schools.
    def schools(school, opts)
      limit = opts[:limit] || 5
      query = "
        SELECT id, street,city, state, name, level, type, level_code,
        #{location_near_formula(school.lat, school.lon)} as distance
        FROM school
        WHERE active = 1 AND
        lat is not null AND
        lon is not null AND
        id != #{school.id}
        #{level_code_filter(school)}
        ORDER BY distance LIMIT #{limit}
      "
      School.on_db(school.shard).find_by_sql(query)
    end

    def location_near_formula(lat, lon)
      miles_center_of_earth = 3959
      "(
      #{miles_center_of_earth} *
       acos(
         cos(radians(#{lat})) *
         cos( radians( `lat` ) ) *
         cos(radians(`lon`) - radians(#{lon})) +
         sin(radians(#{lat})) *
         sin( radians(`lat`) )
       )
     )"
    end

    def level_code_filter(school)
      return '' if school.level_code_array.blank?
      arr_query_str = []
      school.level_code_array.each do |one_level_code|
        arr_query_str << "level_code LIKE '%#{one_level_code}%'"
      end
      arr_query_str.present? ? 'AND (' << arr_query_str.join(" || ") << ')' : ''
    end
  end
end
