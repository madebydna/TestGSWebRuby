class Api::DistrictSerializer
  attr_reader :district

  def initialize(district)
    @district = district
  end

  def to_hash
    rating = district.great_schools_rating if defined? district.great_schools_rating
    h = {
      id: district.id,
      districtName: district.try(:name),
      lat: district.lat,
      lon: district.lon,
      name: district.name,
      address: {
        street1: district['street'],
        street2: district['street_line_2'],
        zip: district['zipcode'],
        city: district['city']
      },
      rating: rating && rating != 'NR' ? rating : nil,
      state: district.state,
      type: 'district',
      schoolCountsByLevelCode: district.school_counts_by_level_code
    }
    if district.respond_to?(:boundaries)
      h[:boundaries] = district.boundaries
    end
    h
  end
end
