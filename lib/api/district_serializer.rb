class Api::DistrictSerializer
  attr_reader :district

  def initialize(district)
    @district = district
  end

  def to_hash
    h = {
      id: district.id,
      districtName: district.try(:name),
      gradeRange: 'TODO',
      grades: 'TODO',
      lat: district.lat,
      lon: district.lon,
      name: district.name,
      address: {
        street1: district['street'],
        street2: district['street_line_2'],
        zip: district['zip'],
        city: district['city']
      },
      rating: (district.great_schools_rating if defined? district.great_schools_rating),
      # districtType: district.type,
      state: district.state,
      type: 'district'
    }
    if district.respond_to?(:boundaries)
      h[:boundaries] = district.boundaries
    end
    h
  end
end
