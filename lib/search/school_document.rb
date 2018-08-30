# frozen_string_literal: true

module Search
  class SchoolDocument
    include Indexable
    include Retrievable

    attr_reader :state, :school_id

    CACHE_KEYS = %w(ratings)

    def initialize(state:, school_id:)
      @state = state
      @school_id = school_id
    end

    # retrievable

    def self.from_unique_key(key)
      state, school_id = key.split('-')
      new(state: state, school_id: school_id)
    end

    # indexable
    
    def self.type
      'School'
    end

    def unique_key
      self.class.unique_key(@state, @school_id)
    end

    def field_values
      return {} unless school
      {
        name_text: school.name,
        sortable_name_s: school.name&.downcase,
        city_s: school.city,
        school_district_id_i: school.district_id,
        school_district_name_s: school.district&.name,
        street_s: school.street&.downcase,
        zipcode_s: school.zipcode,
        county_s: school.county&.downcase,
        state_s: school.state.downcase,
        latlon_ll: latlon,
        summary_rating_i: school.great_schools_rating,
        level_codes_s: school.level_code&.split(',')
      }
    end

    # impl

    def self.unique_key(state, school_id)
      "#{state.downcase}-#{school_id}"
    end

    private

    def school
      @_school ||= begin
        school = School.find_by_state_and_id(@state, @school_id)
        query = SchoolCacheQuery.new.include_cache_keys(CACHE_KEYS).include_schools(@state, @school_id)
        query_results = query.query_and_use_cache_keys
        school_cache_results = SchoolCacheResults.new(CACHE_KEYS, query_results)
        school_cache_results.decorate_schools([school])
        school
      end
    end

    def latlon
      "#{school.lat},#{school.lon}" if school.lat && school.lon
    end

  end
end
