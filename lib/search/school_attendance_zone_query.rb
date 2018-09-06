# frozen_string_literal: true

module Search
  class SchoolAttendanceZoneQuery
    include Pagination::Paginatable

    attr_reader :lat, :lon, :level

    def initialize(lat:, lon:, level:, offset:, limit:)
      @lat = lat
      @lon = lon
      @level = level
      @offset = offset
      @limit = limit
    end

    # This returns one school max based on the level instance variable
    def search
      @_search = begin
        results = SchoolGeometry.schools_having_point_in_attendance_zone(lat, lon, level)
        PageOfResults.new(
          results,
          query: self,
          total: results.size,
          offset: offset,
          limit: limit
        )
      end
    end

    # This returns up to one school per level, ignoring level instance variable
    def search_all_levels
      @_search = begin
        results = SchoolGeometry.all_valid_schools_having_point_in_attendance_zone(lat, lon)
        PageOfResults.new(
            results,
            query: self,
            total: results.size,
            offset: offset,
            limit: limit
        )
      end
    end

    # This returns up to one school per level filtered by the level instance variable
    def search_by_level
      @_search = begin
        results = SchoolGeometry.all_valid_schools_having_point_in_attendance_zone(lat, lon, level)
        PageOfResults.new(
            results,
            query: self,
            total: results.size,
            offset: offset,
            limit: limit
        )
      end
    end
  end
end
