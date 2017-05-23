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
    results = results.where(ed_level: level)
    results
  end

  def self.schools_for_geometries(geometries)
    geometries.map { |geo| geo.school }
  end

end
