# frozen_string_literal: true

module CompareControllerConcerns

  def serialized_schools
    @_serialized_schools ||= schools.map do |school|
        Api::SchoolSerializer.new(school).to_hash if school
    end.compact
  end

  def schools
    @_schools ||= begin
      decorate_schools(page_of_results)
    end
  end

  def page_of_results
    @_page_of_results ||= solr_query.search
  end

  def any_results?
    page_of_results.present?
  end

  def solr_query
    if params[:solr7]
      query_type = Search::SolrSchoolQuery
    else
      query_type = Search::LegacySolrSchoolQuery
    end
    query_type.new(
      state: state,
      sort_name: 'distance',
      level_codes: level_codes,
      lat: lat,
      lon: lon,
      radius: default_compare_radius,
      limit: default_compare_limit,
      with_rating: 'true',
    )
  end

  def null_query
    Search::NullQuery.new
  end

  def decorate_schools(schools)
    schools = assigned_schools + schools if extras.include?('assigned') && page == 1
    extras.each do |extra|
      method = "add_#{extra}"
      schools = send(method, schools) if respond_to?(method, true)
    end
    if cache_keys.any?
      schools = SchoolCacheQuery.decorate_schools(schools, *cache_keys)
      schools = filter_by_ethnicity_test_score_rating(schools).compact
      schools = sort_by_ethnicity_test_score(schools) if sort == nil || sort == 'testscores'
    end
    schools
  end

  def cache_keys
    @_cache_keys ||= []
  end

  def sort_by_ethnicity_test_score(schools)
    # This keeps the pinned school on top
    pinned_school = schools.select {|school| school.pinned}
    non_pinned_schools = schools - pinned_school
    non_pinned_schools.sort_by {|school| [school.test_score_rating_for_ethnicity, -1 * school.distance] }.reverse.unshift(pinned_school[0])
  end

  def filter_by_ethnicity_test_score_rating(schools)
    schools.map do |school|
      rating_for_ethnicity = school.ethnicity_test_score_ratings[ethnicity]
      if rating_for_ethnicity
        school.define_singleton_method(:test_score_rating_for_ethnicity) {rating_for_ethnicity}
        school
      end
    end.compact
  end

  def add_pinned_school(schools)
    schools.select do |school|
      pinned_school_boolean = school.id == school_id.to_i && school.state.downcase == state.downcase ? true : false
      school.define_singleton_method(:pinned) {pinned_school_boolean}
    end
    schools
  end

  def add_saved_schools(schools)
    # grab saved school keys from the cookie (merged with user's msl if they are logged in)
    # and compare to keys constructed from schools.
    schools.each do |school|
      if saved_school_keys&.include?([school.state.downcase, school.id])
        school.define_singleton_method(:saved_school) do
          true
        end
      else
        school.define_singleton_method(:saved_school) do
          false
        end
      end
    end
  end

  # methods for adding extras
  # method names prefixed with add_*
  def add_ratings(schools)
    cache_keys << 'ratings'
    schools
  end

  def add_characteristics(schools)
    cache_keys << 'characteristics'
    schools
  end

  def add_distance(schools)
    return schools unless point_given? || area_given?
    schools.each do |school|
      if school.lat && school.lon
        distance =
          Geo::Coordinate.new(school.lat, school.lon).distance_to(
            Geo::Coordinate.new(lat.to_f, lon.to_f)
          )
        school.define_singleton_method(:distance) do
          distance
        end
      end
    end

    schools
  end

  def default_compare_limit
    100
  end

  def default_compare_radius
    #in miles
    100
  end

  def translated_ethnicity_with_fallback
    @_translated_ethnicity ||= I18n.t(ethnicity) || ethnicity
  end

  def cohort_count_header_hash
    {title: I18n.t('total_students_enrolled', scope: 'controllers.compare_schools_controller'), className: 'total-enrollment', key: 'total-enrollment'}
  end

  def percentage_of_students_by_breakdown_header_hash
    return nil if ethnicity.nil? || ethnicity.downcase == 'all students'
    {title: I18n.t('percentage_of_students', scope: 'controllers.compare_schools_controller', ethnicity: translated_ethnicity_with_fallback), className: 'ethnicity-enrollment', key: 'ethnicity-enrollment'}
  end

  def test_score_rating_by_ethnicity_header_hash
    return nil if ethnicity.nil?
    test_score_rating_key = ethnicity.downcase == 'all students' ? 'test_score_rating_for_all_students' : 'test_score_rating_for'
    {title: I18n.t(test_score_rating_key, scope: 'controllers.compare_schools_controller', ethnicity: translated_ethnicity_with_fallback), className: (sort == 'testscores' ? 'testscores yellow-highlight' : 'testscores'), key: 'testscores'}
  end

  def table_headers
    [cohort_count_header_hash, percentage_of_students_by_breakdown_header_hash, test_score_rating_by_ethnicity_header_hash].compact
  end

end
