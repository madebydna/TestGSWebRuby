# frozen_string_literal: true

module Geo
  class Coordinate
    attr_accessor :lat, :lon

    def initialize(lat, lon)
      @lat = lat
      @lon = lon
    end

    def distance_to(other)
      rad_per_degree = Math::PI / 180
      radius_miles = 3959 # Earth radius
      lat1_rad = lat * rad_per_degree
      lat2_rad = other.lat * rad_per_degree
      lon1_rad = lon * rad_per_degree
      lon2_rad = other.lon * rad_per_degree

      a = Math.sin((lat2_rad - lat1_rad) / 2) ** 2 +
          Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin((lon2_rad - lon1_rad) / 2) ** 2
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

      (radius_miles * c).round(2) # Delta in miles
    rescue StandardError
      nil
    end
  end
end
