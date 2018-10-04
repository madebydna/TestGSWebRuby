# frozen_string_literal: true

module CommunityConcerns
    def serialized_schools
      schools.map do |school|
        Api::SchoolSerializer.new(school).to_hash
      end
    end

    def schools
      decorate_schools(page_of_results)
    end

    def school_levels
      @_school_levels ||= begin
        {}.tap do |sl|
          sl[:all] = school_count('all')
          sl[:public] = school_count('public')
          sl[:private] = school_count('private')
          sl[:charter] = school_count('charter')
          sl[:preschool] = school_count('preschool')
          sl[:elementary] = school_count('elementary')
          sl[:middle] = school_count('middle')
          sl[:high] = school_count('high')
        end
      end
    end

    def fetch_top_rated_schools(level_code)
      set_level_code_params(level_code)
      serialized_schools
    end

    def top_rated_schools
      @_top_rated_schools ||= begin
        elementary = fetch_top_rated_schools('e')
        middle = fetch_top_rated_schools('m')
        high = fetch_top_rated_schools('h')
        {
          schools: {
            elementary: elementary,
            middle: middle,
            high: high,
          },
          counts: {
            elementary: elementary.count,
            middle: middle.count,
            high: high.count,
            all: elementary.count + middle.count + high.count
          }
        }
      end
    end

    def page_of_results
      solr_query.search
    end

    def solr_query
      query_type = Search::SolrSchoolQuery

      if params[:district]
        query_type.new(
          state: state,
          district_id: district_record.id,
          level_codes: [level_code_param].compact,
          limit: default_top_schools_limit,
          sort_name: 'rating',
          with_rating: 'true'
        )
      else
        query_type.new(
          city: city,
          state: state,
          district_name: district_record&.name,
          level_codes: [level_code_param].compact,
          limit: default_top_schools_limit,
          sort_name: 'rating',
          with_rating: 'true'
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

    def district_content_field(district_content, key)
      district_content[key].first['city_value'] if district_content && district_content[key]
    end

    def district_content(city_id)
      @_district_content ||= begin
        if CityCache.district_content_cache(city_id).present?
          dc = CityCache.district_content_cache(city_id).map do |district_content|
            {}.tap do |d|
              name = district_content_field(district_content, 'name')
              city = district_content_field(district_content, 'city')
              d[:id] = district_content_field(district_content, 'id')
              d[:districtName] = name
              d[:grades] = district_content_field(district_content, 'levels')
              d[:numSchools] = district_content_field(district_content, 'school_count')
              d[:url] = district_url(district_params(state, city, name))
              d[:enrollment] =  district_enrollment_cache(district_content_field(district_content, 'id'))
              d[:zip] = district_content_field(district_content, 'zip')
              d[:lat] = district_content_field(district_content, 'lat')
              d[:lon] = district_content_field(district_content, 'lon')
            end
          end
          dc.sort_by { |h| h[:enrollment] ? h[:enrollment] : 0 }.reverse!
        else
          []
        end
      end
    end

    def district_enrollment_cache(district_id)
      dc = DistrictCache.where(name: 'district_characteristics', district_id: district_id, state: state)
      dc_hash = JSON.parse(dc.first.value) if dc.present? && dc.first
      dc_hash['Enrollment'].first['district_value'].to_i if dc_hash && dc_hash['Enrollment'] && dc_hash['Enrollment'].first
    end

    def fetch_district_attr(key)
      district_content(city_record)&.first&.fetch(key, nil) 
    end

end