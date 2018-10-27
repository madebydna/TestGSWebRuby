# frozen_string_literal: true

module SearchControllerConcerns
  def serialized_schools
    # Using a plain rubo object to convert domain object to json
    # decided not to use jbuilder. Dont feel like it adds benefit and
    # results in less flexible/resuable code. Could use
    # active_model_serializers (included with rails 5) but it's yet another
    # gem...
    @_serialized_schools ||= schools.map do |school|
      Api::SchoolSerializer.new(school).to_hash.tap do |s|
        s.except(not_default_extras - extras)
      end
    end
  end

  def schools
    @_schools ||= begin
      decorate_schools(page_of_results)
    end
  end

  def page_of_results
    @_page_of_results ||= results_for_page
  end

  # TODO when old search is put to rest, this can be removed and query.search can be put back in page_of_results
  def results_for_page
    if params['version'] == '1' && location_given? && extras.include?('boundaries')
      attendance_zone_query.search || []
    else
      query.search
    end
  end

  def any_results?
    page_of_results.present?
  end

  def query
    if point_given? || area_given? || q.present?
      solr_query
    elsif state.present? && (school_id.present? || district_id.present?)
      school_sql_query
    else
      solr_query
    end
  end

  def attendance_zone_query
    ::Search::SchoolAttendanceZoneQuery.new(
      lat: lat,
      lon: lon,
      level: boundary_level,
      offset: offset,
      limit: limit
    )
  end

  def school_sql_query
    Search::ActiveRecordSchoolQuery.new(
      state: state,
      id: school_id,
      district_id: district_id,
      entity_types: entity_types,
      city: city,
      lat: lat,
      lon: lon,
      radius: radius,
      level_codes: level_codes,
      sort_name: sort_name,
      offset: offset,
      limit: limit
    )
  end

  def solr_query
    if params[:solr7]
      query_type = Search::SolrSchoolQuery
    else
      query_type = Search::LegacySolrSchoolQuery
    end
    
    query_type.new(
      city: city,
      state: state,
      school_keys: school_keys,
      district_id: district_record&.id,
      district_name: district_record&.name,
      location_label: location_label_param,
      level_codes: level_codes,
      entity_types: entity_types,
      lat: lat,
      lon: lon,
      radius: radius,
      q: q,
      offset: offset,
      limit: limit,
      sort_name: sort_name,
      with_rating: with_rating
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
    end
    schools
  end

  def cache_keys
    @_cache_keys ||= []
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
  def add_summary_rating(schools)
    cache_keys << 'ratings'
    schools
  end

  def add_all_ratings(schools)
    cache_keys << 'ratings'
    schools
  end

  def add_review_summary(schools)
    cache_keys << 'review_summary'
    cache_keys << 'reviews_snapshot'
    schools
  end

  def add_enrollment(schools)
    cache_keys << 'characteristics'
    schools
  end

  def add_students_per_teacher(schools)
    cache_keys << 'gsdata'
    schools
  end

  def add_boundaries(schools)
    schools = Array.wrap(schools)
    if schools.length == 1
      schools = schools.map { |s| Api::SchoolWithGeometry.apply_geometry_data!(s) }
    end
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

  def assigned_schools
    @_assigned_schools ||=
      if location_given? && street_address?
        attendance_zone_query.search_by_level
      else
        []
      end
  end

  def add_assigned(schools)
    assigned_schools.each do | as |
      as.assigned = true
    end

    schools
  end

  def add_subrating_hash
    school.ratings
  end

  def add_ethincity_hash

  end

  def merge_school_keys
    (FavoriteSchool.saved_school_list(current_user.id) + cookies_school_keys).uniq
  end

  def jsonify_school_keys
    result = []
    school_keys.map do |school_pair|
      result << { 
        "state": school_pair.first.upcase,
        "id": school_pair.last.to_s
      }
    end
    result
  end

end