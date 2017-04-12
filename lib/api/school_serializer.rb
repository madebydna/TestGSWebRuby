class Api::SchoolSerializer
  include Rails.application.routes.url_helpers
  include UrlHelper

  attr_reader :school

  def initialize(school)
    @school = school
  end

  def to_hash
    rating = school.great_schools_rating if defined? school.great_schools_rating
    h = {
      id: school.id,
      districtId: school.district_id,
      districtName: school['district_name'],
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
      rating: rating && rating != 'NR' ? rating : nil,
      schoolType: school.type,
      state: school.state,
      type: 'school',
      links: {
        profile: school_path(school)
      }
    }
    if school.respond_to?(:boundaries)
      h[:boundaries] = school.boundaries
    end
    h
  end
end
