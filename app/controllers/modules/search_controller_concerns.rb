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
    query_type = Search::SolrSchoolQuery

    query_type.new(
      city: city,
      state: state,
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

  def decorate_schools(schools)
    schools = assigned_schools + schools if extras.include?('assigned')
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

  # methods for adding extras
  # method names prefixed with add_*
  def add_summary_rating(schools)
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
        attendance_zone_query.search_all_levels
      else
        []
      end
  end

  def add_assigned(schools)
    schools.each do | sr |
      assigned_schools.each do | as |
        sr.assigned ||= sr&.id == as&.id
      end
    end

    schools
  end

end