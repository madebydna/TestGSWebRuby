FactoryBot.define do
  factory :solr_school_result_hash, class:Hash do
    sequence :school_id do |n|
      n
    end
    address "3100 Hawthorne Drive \nDover DE  19901"
    city "Dover"
    community_rating 3
    distance 0.0
    grades ["6", "7", "8"]
    level_code "m"
    level_codes ["m"]
    overall_gs_rating 10
    school_active true
    school_affiliation "None"
    school_county "Kent"
    school_database_state ["de","Delaware"]
    school_district_id 10
    school_grade_level ["m", "junior", "middle"]
    school_grade_range '6-8'
    school_physical_state "de"
    school_size 201
    school_latitude 39.11915969848633
    school_longitude (-75.48863220214844)
    school_name "Dover Air Force Base Middle School"
    school_name_untokenized "Dover Air Force Base Middle School"
    school_profile_path '/delaware/dover/25-Dover-Air-Force-Base-Middle-School/'
    school_review_count 11
    school_review_count_ruby 13
    school_sortable_name "Dover Air Force Base Middle School"
    school_type "public"
    street "3100 Hawthorne Drive"
    state "de"
    state_name "delaware"
    zip "19901"

    initialize_with { attributes.stringify_keys }
  end

  factory :solr_compare_school_result_hash, class:Hash do
      sequence :school_id do |n| 
        n 
      end
      sequence :id do |n| 
        "School ca-#{n}"
      end
      document_type "School"
      name "Piedmont High School"
      sortable_name "piedmont high school"
      city "Piedmont"
      city_untokenized "piedmont"
      school_district_id 15
      school_district_name "Piedmont City Unified School District"
      street "800 magnolia avenue"
      zipcode "94611"
      county "alameda"
      state "ca"
      latlon "37.823673-122.232903"
      level_codes ["h"]
      entity_type "public"
      summary_rating 10
      test_scores_rating 10
      college_readiness_rating 10
      advanced_courses_rating 10
      test_scores_rating_asian 10
      test_scores_rating_hispanic 8
      test_scores_rating_two_or_more_races 10
      test_scores_rating_white 10
      created "2019-08-10T00:45:39.483Z"
      distance 6.7358036 
      initialize_with { attributes.stringify_keys }
    end

  factory :solr_city_result_hash, class:Hash do
    contentKey { "city#ohEdgerton" }
    document_type { "city" }
    city_name { ["Edgerton","Edgerton OH"] }
    city_sortable_name { "Edgerton" }
    city_keyword { "edgerton" }
    city_citystate { "Edgerton OH" }
    city_state { ["oh", "Ohio"] }
    city_number_of_schools { 2 }
    city_latitude { 41.44960021972656 }
    city_longitude { -84.74980163574219 }
    indexedTimestamp { "2016-02-23T15:33:15.165Z" }
    score { "0.0" }
    distance { "51.95931962964157" }

    initialize_with { attributes.stringify_keys }
  end

  factory :solr_school_result_hash_north_name, class:Hash do
    contentKey "school#DE95"
    document_type "school"
    school_id 95
    school_name "North Georgetown Elementary School"
    school_name_untokenized "North Georgetown Elementary School"
    school_name_ordered "North Georgetown Elementary School"
    school_sortable_name "North Georgetown Elementary School"
    school_phone "(302) 855-2430"
    school_fax "(302) 855-2439"
    school_website "www.ng.irsd.k12.de.us"
    school_affiliation "None"
    school_student_teacher_ratio 15
    school_size 874
    street "664 North Bedford Street"
    city "Georgetown"
    citykeyword "georgetown"
    state "de"
    zip "19947"
    address "664 North Bedford Street, \nGeorgetown, DE  19947"
    school_physical_state "de"
    school_grade_range "PK, 1-5"
    school_latitude 38.7060546875
    school_longitude (-75.39826202392578)
    school_county "Sussex"
    school_type "public"
    is_school_for_new_profile true
    is_new_gs_rating true
    school_database_state ["de", "Delaware"]

    initialize_with { attributes.stringify_keys }
  end

  factory :solr_school_result_hash_magnolia, class:Hash do
    contentKey "school#DE33"
    document_type "school"
    school_id 33
    school_name "Magnoila School"
    school_name_untokenized "Magnoila School"
    school_name_ordered "Magnoila School"
    school_sortable_name "Magnoila School"
    school_phone "(302) 335-5039"
    school_fax "(302) 335-3705"
    school_website "www.mci.cr.k12.de.us/"
    school_affiliation "None"
    school_student_teacher_ratio 20
    school_size 525
    street "Post Office Box 258"
    city "Magnolia"
    citykeyword "magnolia"
    state "de"
    zip "19962"
    address "Post Office Box 258, \n11 East Walnut\nMagnolia, DE  19962"
    school_physical_state "de"
    school_grade_range "PK-K"
    school_latitude 39.07052993774414
    school_longitude (-75.47657775878906)
    school_county "Kent"
    school_type "public"
    school_database_state ["de", "Delaware"]

    initialize_with { attributes.stringify_keys }
  end


  factory :solr_alameda_high_school_result_hash, class:Hash do
    contentKey "school#CA1"
    document_type "school"
    school_id 1
    school_nces_code "060177000041"
    school_active true
    scorecard_school "scorecard_school"
    school_name "Alameda High School"
    school_name_untokenized "Alameda High School"
    school_name_ordered "Alameda High School"
    school_sortable_name "Alameda High School"
    school_phone "(510) 337-7022"
    school_fax "(510) 521-4740"
    school_website "http://aus.alamedausd.ca.schoolloop.com/"
    school_affiliation "None"
    school_student_teacher_ratio 22
    school_size 1853
    street "2201 Encinal Avenue"
    city "Alameda"
    citykeyword "alameda"
    state "ca"
    zip "94501"
    address "2201 Encinal Avenue \nAlameda CA 94501"
    school_physical_state "ca"
    school_grade_range "9-12"
    school_latitude 37.76426696777344
    school_longitude (-122.24809265136719)
    school_county "Alameda"
    school_type "public"
    is_school_for_new_profile true
    is_new_gs_rating true
    school_autotext "Alameda's Alameda High School is a public school serving 1853 students in grades 9-12. "
    school_profile_path "/california/alameda/1-Alameda-High-School/"
    school_district_id 1
    school_district_nces_code "0601770"
    school_district_charter_only false
    ratings_count 25
    ratings_activities 4
    ratings_parents 3
    ratings_quality 4
    ratings_safety 4
    ratings_principal 4
    ratings_teachers 4
    community_rating 4
    school_review_count 8
    school_review_blurb "Students here do not reach out to others. Many cliques al"
    school_review_count_ruby 21
    overall_gs_rating 9
    sorted_gs_rating_asc 9
    indexedTimestamp "2016-07-09T08:20:22.558Z"
    arts_performing_written ["drama", "dance"]
    girls_sports ["cheerleading", "cross_country","golf", "softball","tennis", "track","volleyball", "water_polo","swimming", "basketball","soccer"]
    school_grade_level ["h", "high"]
    instructional_model ["individual_instruction", "gifted", "AP_courses"]
    boys_sports ["baseball", "cheerleading", "cross_country", "football", "golf", "tennis", "track", "volleyball", "water_polo", "swimming", "basketball", "soccer"]
    school_schooldistrict_autosuggest ["Alameda High School", "Alameda City Unified School District", "ACUSD"]
    arts_music ["chorus", "band"]
    sports ["baseball", "cheerleading", "cross_country", "football", "golf", "tennis", "track", "volleyball", "water_polo", "swimming", "basketball", "soccer", "cheerleading", "cross_country", "golf", "softball", "tennis", "track", "volleyball", "water_polo", "swimming", "basketball", "soccer"]
    ell_level ["moderate"]
    foreign_language ["cantonese", "french", "spanish"]
    transportation ["none"]
    school_district_name ["Alameda City Unified School District", "ACUSD"]
    collection_id ["14", "15"]
    school_autosuggest ["Alameda High School", "Alameda", "Alameda City Unified School District", "ACUSD"]
    special_ed_programs ["developmental_delay", "blindness", "multiple"]
    staff_resources ["assistant_principal", "music_teacher", "pe_instructor", "dance_teacher"]
    grades ["9", "10", "11", "12"]
    school_database_state ["ca", "California"]
    dress_code ["dress_code"]
    facilities ["computer"]

    initialize_with { attributes.stringify_keys }
  end
end
