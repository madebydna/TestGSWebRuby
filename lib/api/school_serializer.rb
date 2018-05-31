class Api::SchoolSerializer
  include Rails.application.routes.url_helpers
  include UrlHelper

  attr_reader :school

  def initialize(school)
    @school = school
  end

  def to_hash
    rating = school.great_schools_rating if defined? school.great_schools_rating || school.respond_to?(:great_schools_rating)
    enrollment = school.students_enrolled if school.respond_to?(:students_enrolled) || school.singleton_class.method_defined?(:students_enrolled)
    distance = school.distance if school.respond_to?(:distance) || school.singleton_class.method_defined?(:distance)
    rating = rating && rating != 'NR' ? rating.to_i : nil
    h = {
      id: school.id,
      districtId: school.district_id,
      districtName: school['district_name'],
      levelCode: school.level_code,
      lat: school.lat,
      lon: school.lon,
      name: school.name,
      gradeLevels: school.process_level,
      address: {
        street1: school['street'],
        street2: school['street_line_2'],
        zip: school['zipcode'],
        city: school['city']
      },
      rating: rating,
      ratingScale: rating ? SchoolProfiles::SummaryRating.scale(rating) : nil,
      schoolType: school.type,
      state: school.state,
      type: 'school',
      links: {
        profile: school_path(school)
      },
      highlighted: false
    }
    if enrollment
      h[:enrollment] = enrollment&.to_i
    end
    if school.respond_to?(:boundaries)
      h[:boundaries] = school.boundaries
    end
    if school.respond_to?(:star_rating) || defined? school.star_rating
      h[:parentRating] = school.star_rating
    end
    if school.respond_to?(:num_reviews) || defined? school.num_reviews
      h[:numReviews] = school.num_reviews
    end
    if distance
      h[:distance] = distance
    end

    h
  end
end
