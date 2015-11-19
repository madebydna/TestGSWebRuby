class NearbySchoolsCaching::Methodologies::TopNearbySchools < NearbySchoolsCaching::Methodologies
  NAME = 'top_nearby_schools'.freeze
  COUNT_FIELD = 'count'.freeze
  AVERAGE_FIELD = 'average'.freeze
  DISTANCE_FIELD = 'distance'.freeze

  class << self

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

    # The average is done by adding all of the ratings fields together by the
    # number of results a school has for those ratings fields.
    def rating_average_select(ratings)
      "(
        (#{ratings.map { |r| options_as_unique_name(r) }.join(' + ')}) / #{COUNT_FIELD}
       )"
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
       #{level_code_filter(school)}
       AND #{distance_from_school(school)} <= #{radius}"
    end

    def ratings_select_statements(ratings)
      ratings.inject([]) do |q, rating|
        q << rating_select_statement(rating)
      end.join(',')
    end

    # If a school does not have this rating, give it a 0 so that when added to
    # its others ratings there is no affect. We also have a dynamic denominator
    # for each school so we won't do anything bogus like (10 + 0) / 2, it would
    # instead be the correct (10 + 0) / 1.
    def rating_select_statement(rating)
      "IFNULL((
          SELECT value_float
          FROM TestDataSchoolValue
          JOIN TestDataSet tds on tds.id = data_set_id
          WHERE #{basic_ratings_conditions}
          AND #{options_as_where_clause(rating)}
        ), 0) as #{options_as_unique_name(rating)}"
    end

    # Count up how many of the desired ratings each school has so that we can
    # correctly average together the schools' ratings.
    def number_of_ratings_select_statement(ratings)
      "(
        SELECT count(*)
        FROM TestDataSchoolValue
        JOIN TestDataSet tds on tds.id = data_set_id
        WHERE #{basic_ratings_conditions}
        AND (#{ratings.map { |r| options_as_where_clause(r) }.join(' OR ')})
      ) as #{COUNT_FIELD}"
    end

    # Grab each school's ratings that are deemed the most up-to-date.
    # display_target is how we set ratings to be used.
    def basic_ratings_conditions
      "(display_target like '%ratings%' AND school_id = school.id)"
    end

    def options_as_where_clause(options)
      '(' << options.inject('') do |where_clause, (column, value)|
        where_clause << "#{column} = '#{value}' AND "
      end.chomp('AND ') << ')'
    end

    def options_as_unique_name(options)
      options.to_a.join
    end
  end
end
