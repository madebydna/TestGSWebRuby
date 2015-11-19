class NearbySchoolsCaching::Methodologies::ClosestTopSchools < NearbySchoolsCaching::Methodologies
  NAME = 'closest_top_schools'.freeze
  AVERAGE_FIELD = 'average'.freeze
  DISTANCE_FIELD = 'distance'.freeze

  class << self
    include NearbySchoolsCaching::Helpers::RatingsHelper

    # For the given ratings, find the closest school with an average rating of
    # at least the configured minimum.
    def schools(school, opts)
      limit   = opts[:limit] || 1 # number of schools to return
      minimum  = opts[:minimum] || 8 # Minimum average rating to consider

      # opts[:ratings] defines which ratings to use. If multiple ratings are
      # given, then the metric is the average of the two.
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
      "SELECT *, #{rating_average_select(ratings)} as #{AVERAGE_FIELD}
       FROM (#{inner_query(school, ratings)}) as inner_table
       WHERE #{rating_average_select(ratings)} >= #{minimum}
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
  end
end
# SELECT *, (
#  (data_type_id174breakdown_id1 + data_type_id174breakdown_id8) / count
#  ) as average
#   FROM (SELECT school.id,
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
#    ), 0) as data_type_id174breakdown_id1,
#   IFNULL((
#     SELECT value_float
#     FROM TestDataSchoolValue
#     JOIN TestDataSet tds on tds.id = data_set_id
#     WHERE (display_target like '%ratings%' AND school_id = school.id)
#     AND (data_type_id = '174' AND breakdown_id = '8' )
#    ), 0) as data_type_id174breakdown_id8,
#   (
#    SELECT count(*)
#    FROM TestDataSchoolValue
#    JOIN TestDataSet tds on tds.id = data_set_id
#    WHERE (display_target like '%ratings%' AND school_id = school.id)
#    AND (
#      (data_type_id = '174' AND breakdown_id = '1' ) OR
#      (data_type_id = '174' AND breakdown_id = '8' )
#    )
#   ) as count,
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
#  ) as inner_table
#  WHERE (
#    (data_type_id174breakdown_id1 + data_type_id174breakdown_id8) / count
#  ) >= 8
#  ORDER BY distance ASC
#  LIMIT 1
