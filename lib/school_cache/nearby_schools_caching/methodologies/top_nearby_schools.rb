class NearbySchoolsCaching::Methodologies::TopNearbySchools < NearbySchoolsCaching::Methodologies
  NAME = 'top_nearby_schools'.freeze
  AVERAGE_FIELD = 'average'.freeze
  DISTANCE_FIELD = 'distance'.freeze

  class << self
    include NearbySchoolsCaching::Helpers::RatingsHelper

    # Within the given radius, order schools by the average of the configured
    # ratings types. The results are orderd by rating average desc, distance
    # asc, so in a tie, the closer school wins.
    def schools(school, opts)
      limit   = opts[:limit] || 5 # number of schools to return
      radius  = opts[:radius] || 2 # miles

      # opts[:ratings] defines which ratings to use. If multiple ratings are
      # given, then the metric is the average of the two.
      #
      # Ex:
      # [
      #   { data_type_id: 174, breakdown_id: 1 },
      #   { data_type_id: 174, breakdown_id: 9 }
      # ]
      ratings = opts[:ratings]

      top_nearby_schools_query = query(school, ratings, radius, limit)
      School.on_db(school.shard).find_by_sql(top_nearby_schools_query)
    end

    protected

    # TODO Add commented out query at the bottom of this file
    def query(school, ratings, radius, limit)
      "SELECT *, #{rating_average_select(ratings)} as #{AVERAGE_FIELD}
       FROM (#{inner_query(school, ratings, radius)}) as inner_table
       ORDER BY #{rating_average_select(ratings)} DESC, #{DISTANCE_FIELD} ASC
       LIMIT #{limit}"
    end

    # This inner query does some initial calculations like converting null
    # ratings to 0s and counting up how many of the desired ratings we want.
    def inner_query(school, ratings, radius)
      "SELECT #{basic_nearby_schools_fields},
       #{ratings_select_statements(ratings)},
       #{number_of_ratings_select_statement(ratings)},
       #{distance_from_school(school)} as #{DISTANCE_FIELD}
       FROM school
       WHERE #{basic_nearby_schools_conditions(school)}
       AND #{distance_from_school(school)} <= #{radius}"
    end
  end
end
