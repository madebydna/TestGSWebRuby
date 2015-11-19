class NearbySchoolsCaching::Methodologies::ClosestSchools < NearbySchoolsCaching::Methodologies
  NAME = 'closest_schools'.freeze

  class << self

    # The closest schools that serve similar grade levels. The list is returned
    # in distance order, smallest to largest.
    def schools(school, opts)
      limit = opts[:limit] || 5
      query = "
        SELECT #{basic_nearby_schools_fields},
        #{distance_from_school(school)} as distance
        FROM school
        WHERE #{basic_nearby_schools_conditions(school)}
        ORDER BY distance LIMIT #{limit}
      "
      School.on_db(school.shard).find_by_sql(query)
    end
  end
end
