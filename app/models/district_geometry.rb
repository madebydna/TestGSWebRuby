class DistrictGeometry < ActiveRecord::Base
  db_magic :connection => :us_geo
  self.table_name = 'school_district_geometry'

  scope :containing_point, -> (lat,lon) { where("ST_contains(geom, point(?,?))", lon, lat) }

  scope :order_by_area, -> { order('ST_area(geom) ASC') }

  def district
    @_district ||= District.on_db(state.to_s.downcase.to_sym).find_by(active:1, id: district_id)
  end

  def coordinates
    factory = ::RGeo::Geographic.simple_mercator_factory
    multi_polygon = factory.parse_wkt(geom)
    multi_polygon.boundary.coordinates
  end

  def self.find_by_point_and_level(lat, lon, level_code)
    results = DistrictGeometry.select('*, AsText(geom) as geom').
      containing_point(lat,lon).
      order_by_area
    results = results.where("level_code LIKE ?", "%#{level_code}%")
    results
  end

  def self.districts_for_geometries(geometries)
    geometries.map { |geo| geo.district }
  end



end
