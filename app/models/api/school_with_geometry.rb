class Api::SchoolWithGeometry < SimpleDelegator
  attr_accessor :boundaries

  def self.apply_geometry_data!(school)
    geometries = 
      SchoolGeometry.select('ed_level, AsText(geom) as geom').
      where(state: school.state, school_id: school.id)

    new(school).tap do |s|
      s.boundaries = geometries.each_with_object({}) do |result, hash|
        next unless result['geom'] 
        coordinates = self.geom_to_coordinates(result['geom'])
        if coordinates
          hash[result['ed_level']] = {
            coordinates: coordinates
          }
        end
      end
    end
  end

  def self.geom_to_coordinates(geom)
    # multipolygon = rgeo_factory.parse_wkt(geom) rescue nil
    # multipolygon.boundary.coordinates if multipolygon
    # eval(geom.gsub('MULTIPOLYGON', '').gsub('POLYGON', '').gsub('(', '[').gsub(')', ']').gsub(',', '],[').gsub(' ', ','))

    eval(
      '[' + geom.
        gsub('MULTIPOLYGON', '').
        gsub('POLYGON', '').
        gsub('(', '[').
        gsub(')', ']').
        gsub(',', '],[').
        gsub(' ', ',') + ']'
    )
  end

  # def self.rgeo_factory
    # @_rgeo_factory ||= ::RGeo::Geographic.simple_mercator_factory
    # proj4 = "+proj=lcc +lat_1=41.03333333333333 +lat_2=40.66666666666666 +lat_0=40.16666666666666 +lon_0=-74 +x_0=300000.0000000001 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs"
    # @_rgeo_factory ||= ::RGeo::Geographic.projected_factory(:projection_proj4 => proj4, :projection_srid => 2263)
  # end
end
