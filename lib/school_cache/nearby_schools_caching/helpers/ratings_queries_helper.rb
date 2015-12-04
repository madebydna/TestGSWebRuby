module NearbySchoolsCaching::Helpers::RatingsQueriesHelper
  COUNT_FIELD = 'count'.freeze

  # The average is done by adding all of the ratings fields together by the
  # number of results a school has for those ratings fields.
  def rating_average_select(ratings)
    "(
      (#{ratings.map { |r| options_as_unique_name(r) }.join(' + ')}) / #{COUNT_FIELD}
      )"
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

  # Converts a hash to a valid SQL where statement with each hash key-value
  # being joined together with ' AND '
  def options_as_where_clause(options)
    '(' << options.inject('') do |where_clause, (column, value)|
      where_clause << "#{column} = '#{value}' AND "
    end.chomp('AND ') << ')'
  end

  def options_as_unique_name(options)
    options.to_a.join
  end
end
