class Api::DistrictWithGeometry < SimpleDelegator
  attr_accessor :boundaries

  def self.apply_geometry_data!(district)
    geometries = 
      DistrictGeometry.select('level_code, AsText(geom) as geom').
      where(state: district.state, district_id: district.id)

    new(district).tap do |s|
      s.boundaries = geometries.each_with_object({}) do |result, hash|
        next unless result['geom'] 
        coordinates = self.geom_to_coordinates(result['geom'])
        if coordinates
          hash[result['level_code']] = {
            coordinates: coordinates
          }
        end
      end
    end
  end

  def self.geom_to_coordinates(geom)
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
end
