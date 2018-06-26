class SchoolGeometry < ActiveRecord::Base
  db_magic :connection => :us_geo
  self.table_name = 'school_geometry'

  attr_accessor :school

  scope :containing_point, -> (lat,lon) { where("ST_contains(geom, point(?,?))", lon, lat) }

  scope :order_by_area, -> { order('ST_area(geom) ASC') }

  def school
    @school ||= School.on_db(state.downcase.to_sym).find_by(id: school_id)
  end

  # level is one or more of [O,P,M,H]
  def self.find_by_point_and_level(lat, lon, level)
    results = SchoolGeometry.select('*, AsText(geom) as geom, ST_area(geom) as area').
      containing_point(lat,lon).
      order_by_area
    results = results.where(ed_level: level).where.not(school_id: nil)
    results
  end

  def self.schools_for_geometries(geometries)
    geometries.map { |geo| geo.school }.compact
  end

  def self.schools_having_point_in_attendance_zone(lat, lon, level_code)
    geometries = find_by_point_and_level(lat, lon, level_code)
    school_level_filter_by_attendance_zone(geometries)
  end

  def self.school_level_filter_by_attendance_zone(geometries)
    geometries_valid = geometries.present?
    if geometries && geometries.size > 1 && geometries[0].area == geometries[1].area
      # A geometry is not valid if it covers the same area as the next one
      # This is because we can't really recommend one of those boundaries above the other
      geometries_valid = false
    end
    geometries_valid ? [geometries.first.school].compact : []
  end

  def self.all_valid_schools_having_point_in_attendance_zone(lat, lon, levels=nil)
    all_levels = levels || %w(o p m h)
    geometries = find_by_point_and_level(lat, lon, all_levels)
    if geometries.present?
      all_levels.map do |level|
        geo_for_level = geometries.select{ |obj| obj['ed_level'] == level.upcase }
        school_level_filter_by_attendance_zone(geo_for_level)
      end.flatten
    else
      []
    end
  end

end