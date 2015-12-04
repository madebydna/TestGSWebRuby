class NearbySchoolsCaching::Methodologies::ClosestTopSchools < NearbySchoolsCaching::Methodologies
  NAME = 'closest_top_schools'.freeze
  AVERAGE_FIELD = 'average'.freeze
  DISTANCE_FIELD = 'distance'.freeze
  COUNT_FIELD = NearbySchoolsCaching::Helpers::RatingsQueriesHelper::COUNT_FIELD

  class << self
    include NearbySchoolsCaching::Helpers::RatingsQueriesHelper

    # For all of the given ratings, find the closest schools with a rating of
    # at least the configured minimum.
    def schools(school, opts)
      return [] unless school.lat.present? && school.lon.present?
      limit   = opts[:limit] || 1 # number of schools to return
      minimum  = opts[:minimum] || 8 # Minimum average rating to consider

      # opts[:ratings] defines which ratings to use.
      #
      # Ex:
      # [
      #   { data_type_id: 174, breakdown_id: 1 },
      #   { data_type_id: 174, breakdown_id: 9 }
      # ]
      ratings = opts[:ratings]

      closest_top_schools_query = query(school, ratings, minimum, limit)
      School.on_db(school.shard).find_by_sql(closest_top_schools_query)
    end

    protected

    # Sample query at the bottom of this file
    def query(school, ratings, minimum, limit)
      "SELECT *, '#{NAME}' as methodology
       FROM (#{inner_query(school, ratings)}) as inner_table
       WHERE #{only_schools_with_ratings_meeting_the_minimum(ratings, minimum)}
       ORDER BY #{DISTANCE_FIELD} ASC
       LIMIT #{limit}"
    end

    def inner_query(school, ratings)
      "SELECT #{basic_nearby_schools_fields},
       #{ratings_select_statements(ratings)},
       #{number_of_ratings_select_statement(ratings)},
       #{distance_from_school(school)} as #{DISTANCE_FIELD}
       FROM school
       WHERE #{basic_nearby_schools_conditions(school)}"
    end

    def only_schools_with_ratings_meeting_the_minimum(ratings, minimum)
      clause = ratings.map do |r|
        field_name = options_as_unique_name(r)
        "(#{field_name} >= #{minimum} OR #{field_name} = 0)"
      end
      "(#{clause.join(' AND ')}) AND #{COUNT_FIELD} > 0"
    end
  end
end
# SELECT *, 'closest_top_schools' as methodology
#  FROM (SELECT school.id,
#   school.street,
#   school.city,
#   school.state,
#   school.name,
#   school.level,
#   school.type,
#   school.level_code,
#   IFNULL((
#     SELECT value_float
#     FROM TestDataSchoolValue
#     JOIN TestDataSet tds on tds.id = data_set_id
#     WHERE (display_target like '%ratings%' AND school_id = school.id)
#     AND (data_type_id = '174' AND breakdown_id = '1' )
#   ), 0) as data_type_id174breakdown_id1,IFNULL((
#     SELECT value_float
#     FROM TestDataSchoolValue
#     JOIN TestDataSet tds on tds.id = data_set_id
#     WHERE (display_target like '%ratings%' AND school_id = school.id)
#     AND (data_type_id = '174' AND breakdown_id = '9' )
#   ), 0) as data_type_id174breakdown_id8,
#   (
#    SELECT count(*)
#    FROM TestDataSchoolValue
#    JOIN TestDataSet tds on tds.id = data_set_id
#    WHERE (display_target like '%ratings%' AND school_id = school.id)
#    AND ((data_type_id = '174' AND breakdown_id = '1' ) OR (data_type_id = '174' AND breakdown_id = '9' ))
#   ) as count,
#   (
#     3959 *
#     acos(
#      cos(radians(34.119644)) *
#      cos( radians( `lat` ) ) *
#      cos(radians(`lon`) - radians(-118.463676)) +
#      sin(radians(34.119644)) *
#      sin( radians(`lat`) )
#     )
#  ) as distance
#  FROM school
#  WHERE school.active = 1 AND
#  school.id != 2354 AND
#  school.lat is not null AND
#  school.lon is not null
#  AND (school.level_code LIKE '%e%')) as inner_table
# WHERE ((data_type_id174breakdown_id1 >= 8 OR data_type_id174breakdown_id1 = 0) AND (data_type_id174breakdown_id8 >= 8 OR data_type_id174breakdown_id8 = 0)) AND count > 0
# ORDER BY distance ASC
# LIMIT 1
