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
  end
end
