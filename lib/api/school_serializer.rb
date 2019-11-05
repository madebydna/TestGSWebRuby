class Api::SchoolSerializer
  include Rails.application.routes.url_helpers
  include UrlHelper

  attr_reader :school, :assigned

  def initialize(school)
    @school = school
  end

  def value_from_decorated_school(school, method)
    if school.respond_to?(method) || school.singleton_class.method_defined?(method)
      return school.send(method) 
    end
    return nil
  end



  def to_hash
    rating = school.great_schools_rating if defined? school.great_schools_rating || school.respond_to?(:great_schools_rating)
    rating = rating && rating != 'NR' ? rating.to_i : nil
    # rating_subrating_hash = build_rating_subrating_hash
    # rating_ethnicity_hash = school.subratings
    {
      id: school.id,
      districtId: school.district_id,
      districtName: school['district_name'] || school&.try(:district_name),
      districtCity: school&.try(:school_district_city),
      levelCode: school.level_code,
      lat: school.lat,
      lon: school.lon,
      name: school.name,
      gradeLevels: school.process_level,
      assigned: school.assigned,
      address: {
        street1: school['street'],
        street2: school['street_line_2'],
        zip: school['zipcode'],
        city: school['city']
      },
      csaAwardYears: school.csa_award_winner_years,
      rating: rating,
      ratingScale: rating ? SchoolProfiles::SummaryRating.scale(rating) : nil,
      schoolType: school.type,
      state: school.state.upcase,
      type: 'school',
      links: {
        profile: school_path(school, lang: I18n.current_non_en_locale),
        reviews: school_path(school, lang: I18n.current_non_en_locale) + '#Reviews',
        collegeSuccess: school_path(school, lang: I18n.current_non_en_locale)+ '#College_success'
      },
      highlighted: false,
      pinned: (school.pinned if school.respond_to?(:pinned)),
      testScoreRatingForEthnicity: (school.test_score_rating_for_ethnicity if school.methods.include?(:test_score_rating_for_ethnicity)),
      percentLowIncome: school.free_and_reduced_lunch,
      collegePersistentData: school.stays_2nd_year,
      collegeEnrollmentData: school.enroll_in_college
    }.tap do |h|
      enrollment = value_from_decorated_school(school, :numeric_enrollment)
      students_per_teacher = value_from_decorated_school(school, :ratio_of_students_to_full_time_teachers)
      five_star_rating = value_from_decorated_school(school, :star_rating)
      num_reviews = value_from_decorated_school(school, :num_reviews)
      distance = value_from_decorated_school(school, :distance)
      subratings = value_from_decorated_school(school, :subratings)
      ethnicity_information = value_from_decorated_school(school, :ethnicity_information_for_tableview)
      compare_ethnicity_breakdowns = value_from_decorated_school(school, :ethnicity_breakdowns)
      saved_school = value_from_decorated_school(school, :saved_school)
      h[:boundaries] = school.boundaries if school.respond_to?(:boundaries)
      h[:enrollment] = enrollment&.to_i if enrollment
      h[:parentRating] = five_star_rating if five_star_rating
      h[:numReviews] = num_reviews if num_reviews
      h[:distance] = distance.round(2) if distance
      h[:studentsPerTeacher] = students_per_teacher if students_per_teacher
      h[:subratings] = subratings if subratings
      h[:ethnicityInfo] = ethnicity_information if ethnicity_information
      h[:ethnicityBreakdowns] = compare_ethnicity_breakdowns if compare_ethnicity_breakdowns && school.respond_to?(:pinned)
      h[:savedSchool] = saved_school if saved_school
      h[:remediationData] = school.graduates_remediation_for_college_success_awards
    end
  end
end
