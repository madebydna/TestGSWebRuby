# frozen_string_literal: true

module Search
  class SchoolAttendanceZoneQuery
    include Pagination::Paginatable

    attr_reader :lat, :lon, :level

    def initialize(lat:, lon:, level:)
      @lat = lat
      @lon = lon
      @level = level
    end

    def search
      @_search = begin
        results = School.having_point_in_attendance_zone(lat, lon, level)
        PageOfResults.new(
          results,
          query: self,
          total: results.size
        )
      end
    end
  end
end
