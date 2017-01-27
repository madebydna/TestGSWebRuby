class Api::SchoolSerializer
  attr_reader :school

  def initialize(school)
    @school = school
  end

  def to_hash
    h = {
      id: school.id,
      districtId: school.district_id,
      districtName: school.district.try(:name),
      gradeRange: 'TODO',
      levelCode: school.level_code,
      lat: school.lat,
      lon: school.lon,
      name: school.name,
      address: {
        street1: school['street'],
        street2: school['street_line_2'],
        zip: school['zipcode'],
        city: school['city']
      },
      rating: (school.great_schools_rating if defined? school.great_schools_rating),
      schoolType: school.type,
      state: school.state,
      type: 'school'
    }
    if school.respond_to?(:boundaries)
      h[:boundaries] = school.boundaries
    end
    h
  end
end
