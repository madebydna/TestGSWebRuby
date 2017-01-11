class SchoolGeometry < ActiveRecord::Base
  db_magic :connection => :us_geo
  self.table_name = 'school_geometry'

  scope :containing_point, -> (lat,lon) { where("ST_contains(geom, point(?,?))", lon, lat) }

  scope :order_by_area, -> { order('ST_area(geom) ASC') }
end
