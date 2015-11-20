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
# Sample query:
# SELECT school.id,
#   school.street,
#   school.city,
#   school.state,
#   school.name,
#   school.level,
#   school.type,
#   school.level_code,
#   (
#     3959 *
#     acos(
#       cos(radians(37.889832)) *
#       cos( radians( `lat` ) ) *
#       cos(radians(`lon`) - radians(-122.295151)) +
#       sin(radians(37.889832)) *
#       sin( radians(`lat`) )
#     )
#   ) as distance
#   FROM school
#   WHERE active = 1 AND
#     id != 21 AND
#     lat is not null AND
#     lon is not null
#     AND (level_code LIKE '%e%')
#   ORDER BY distance LIMIT 5
