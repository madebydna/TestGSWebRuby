FactoryGirl.define do

  factory :school_search_result do
    attributes = {
      id: 25,
      scorecard_school: 'scorecard_school',
      street: "3100 Hawthorne Drive",
      city: "Dover",
      state: "de",
      zip: "19901",
      address: "3100 Hawthorne Drive \nDover DE  19901",
      is_school_for_new_profile: true,
      is_new_gs_rating: false,
      facebook_url: "http://www.facebook.com/pages/Dover-Air-Force-Base-Middle-School/163487573679355",
      ratings_count: 13,
      ratings_activities: 4,
      ratings_parents: 4,
      ratings_quality: 4,
      ratings_safety: 4,
      ratings_principal: 4,
      ratings_teachers: 4,
      community_rating: 4,
      overall_gs_rating: 10,
      sorted_gs_rating_asc: 10,
      indexedTimestamp: "2014-07-08T10:56:31.304Z",
      grades: ["6" "7" "8"],
      nces_code: "100018000041,",
      active: true,
      name: "Dover Air Force Base Middle School",
      name_untokenized: "Dover Air Force Base Middle School",
      sortable_name: "Dover Air Force Base Middle School",
      phone: "(302) 674-3284",
      fax: "(302) 730-4283",
      website: "www.dabm.cr.k12.de.us/",
      affiliation: "None",
      student_teacher_ratio: 10,
      size: 201,
      physical_state: "de",
      latitude: 39.11915969848633,
      longitude: -75.48863220214844,
      county: "Kent",
      type: "public",
      autotext: "Dover's Dover Air Force Base Middle School is a public school serving 201 students in grades 6-8. ",
      district_id: 10,
      district_nces_code: "1000180",
      district_charter_only: false,
      review_count: 11,
      review_blurb: "We placed our child at DABM through school choice",
      district_name: ["Caesar Rodney School District" "CRSD"],
      grade_level: ["m" "junior" "middle"],
      database_state: ["de" "Delaware"],
      zipcode: "19901",
      level: ["6" "7" "8"],
      enrollment: 201,
      state_name: "delaware",
      school_media_first_hash: nil,
      level_code: "m",
      level_codes: ["m"]
    }

    initialize_with { SchoolSearchResult.new(attributes) }

    # fit_score 0
    # fit_score_filters {}
    # on_page true
  end
end