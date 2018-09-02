# frozen_string_literal: true

module CommunityConcerns
    def serialized_schools
      @_serialized_schools ||= begin
        schools.map do |school|
          Api::SchoolSerializer.new(school).to_hash
        end
      end
    end

    def schools
      @_schools ||= begin
        decorate_schools(page_of_results)
      end
    end

    def school_levels
      @_school_levels ||= begin
        {}.tap do |sl|
          sl[:all] = school_count('all') || 0
          sl[:public] = school_count('public') || 0
          sl[:private] = school_count('private') || 0
          sl[:charter] = school_count('charter') || 0
          sl[:preschool] = school_count('preschool') || 0
          sl[:elementary] = school_count('elementary') || 0
          sl[:middle] = school_count('middle') || 0
          sl[:high] = school_count('high') || 0
        end
      end
    end

    def page_of_results
      @_page_of_results ||= solr_query.search
    end

    def solr_query
      if params[:solr7]
        query_type = Search::SolrSchoolQuery
      else
        query_type = Search::LegacySolrSchoolQuery
      end

      if params[:district]
        query_type.new(
          state: state,
          district_id: district_record.id,
          level_codes: [level_code].compact,
          limit: default_top_schools_limit,
          sort_name: 'rating',
          with_rating: true
        )
      else
        query_type.new(
          city: city,
          state: state,
          district_name: district_record&.name,
          level_codes: [level_code].compact,
          limit: default_top_schools_limit,
          sort_name: 'rating',
          with_rating: true
        )
      end
    end

    def default_top_schools_limit
      5
    end

    def decorate_schools(schools)
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