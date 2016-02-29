FactoryGirl.define do
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
    school_longitude -75.48863220214844
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
    school_longitude -75.39826202392578
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
    school_longitude -75.47657775878906
    school_county "Kent"
    school_type "public"
    school_database_state ["de", "Delaware"]

    initialize_with { attributes.stringify_keys }
  end

end
