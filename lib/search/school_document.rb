# frozen_string_literal: true

module Search
  class SchoolDocument
    include Indexable
    include Retrievable

    attr_reader :state, :school_id

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
        name_s: school.name,
        city_s: school.city.downcase,
        street_s: school.street&.downcase,
        zipcode_s: school.zipcode,
        county_s: school.county&.downcase,
        state_s: school.state.downcase,
        latlon_ll: latlon,
        summary_rating_i: gsdata_query.summary_rating
      }
    end

    # impl

    def self.unique_key(state, school_id)
      "#{state.downcase}-#{school_id}"
    end

    private

    def gsdata_query
      @_gsdata_query ||= DataValuesForSchoolQuery
        .new(state: @state, school_id: @school_id)
        .include_summary_rating
        .run
    end

    def school
      @_school = School.find_by_state_and_id(@state, @school_id)
    end

    def latlon
      "#{school.lat},#{school.lon}" if school.lat && school.lon
    end

  end
end
