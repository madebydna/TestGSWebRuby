FactoryBot.define do
  factory :school_cache, class: SchoolCache do
    name :name
    school_id :school_id
    state :state
    value :value
    updated Time.now
  end

  factory :cached_ratings, class: SchoolCache do
    name 'ratings'
    sequence(:school_id) { |n| n }
    state 'ca'
    value :value
    updated Time.now

    trait :with_gs_rating do
      transient do
        gs_rating_value 5.0
      end
      before(:create) do |cached_ratings, evaluator|
        cached_ratings.value = {
            'Summary Rating' =>
                [{
                    'school_value' => evaluator.gs_rating_value,
                    'source_date_valid' => '20171109 11:03:22',
                    'source_name' => 'GreatSchools'
                }]
        }.to_json
      end
    end

    trait :with_test_score_rating do
      transient do
        test_score_rating_value 6.0
      end
      before(:create) do |cached_ratings, evaluator|
        cached_ratings.value = {
            'Test Score Rating' =>
                [{
                     'school_value' => evaluator.test_score_rating_value,
                     'source_date_valid' => '20171109 11:03:22',
                     'source_name' => 'GreatSchools'
                 }]
        }.to_json
      end
    end

    trait :with_test_score_and_gs_rating do
      transient do
        gs_rating_value 5.0
        test_score_rating_value 6.0
      end
      before(:create) do |cached_ratings, evaluator|
        cached_ratings.value = {
            'Summary Rating' =>
                [{
                     'school_value' => evaluator.gs_rating_value,
                     'source_date_valid' => '20171109 11:03:22',
                     'source_name' => 'GreatSchools'
                 }],
            'Test Score Rating' =>
                [{
                     'school_value' => evaluator.test_score_rating_value,
                     'source_date_valid' => '20171109 11:03:22',
                     'source_name' => 'GreatSchools'
                 }]
        }.to_json
      end
    end
  end

  factory :cached_state_rating_with_e_and_m_levels, class: SchoolCache do
    name 'ratings'
    sequence(:school_id) { |n| n }
    state 'ca'
    value ([
      {
        'data_type_id' => 188,
        'year' => 2014,
        'level_code' => 'm',
        'school_value_text' => 'M',
        'school_value_float' => nil,
        'name' => 'State rating'
      },
      {
        'data_type_id' => 188,
        'year' => 2014,
        'level_code' => 'e',
        'school_value_text' => 'E',
        'school_value_float' => nil,
        'name' => 'State rating'
      }
    ].to_json)
    updated Time.now
  end
  factory :cached_state_rating_with_elementary_level, class: SchoolCache do
    name 'ratings'
    sequence(:school_id) { |n| n }
    state 'ca'
    value ([
      {
        'data_type_id' => 188,
        'year' => 2014,
        'level_code' => 'e',
        'school_value_text' => 'C',
        'school_value_float' => nil,
        'name' => 'State rating'
      }
    ].to_json)
    updated Time.now
  end

  factory :cached_state_rating, class: SchoolCache do
    name 'ratings'
    sequence(:school_id) { |n| n }
    state 'ca'
    value ([
      {
        'data_type_id' => 188,
        'year' => 2014,
        'school_value_text' => 'FOO',
        'school_value_float' => nil,
        'name' => 'State rating'
      }
    ].to_json)
    updated Time.now
  end

  factory :cached_gs_rating, class: SchoolCache do
    name 'ratings'
    sequence(:school_id) { |n| n }
    state 'ca'
    value ({
        'Summary Rating' =>
            [{
                 'school_value' => 5,
                 'source_date_valid' => '20171109 11:03:22',
                 'source_name' => 'GreatSchools'
             }]
    }.to_json)
    updated Time.now
  end

  factory :cached_enrollment, class: SchoolCache do
    name 'metrics'
    sequence(:school_id) { |n| n }
    state 'ca'
    value ({
      'Enrollment' => [
        "year" => 2012,
        "source" => "NCES",
        "grade" => "All",
        "school_value" => 1200.0,
        "district_average" => 3803.0,
        "created" => "2014-05-02T08:42:51-07:00"
      ]
    }.to_json)
    updated Time.now
  end

  factory :ca_caaspp_schoolwide_ela_2015, class: SchoolCache do
    name 'test_scores'
    sequence(:school_id) { |n| n }
    state 'ca'
    value ({
    "236" => {
      "All" => {
        "grades" => {
          "All" => {
            "label" => "School-wide",
            "level_code" => {
              "e,m,h" => {
                "English Language Arts" => {
                  "2015" => {
                      "number_students_tested" => 500,
                      "score" => 42.42,
                      "state_average" => 44.0
                  }
                }
              }
            }
          }
        },
        "lowest_grade" => 0,
        "test_description" => "A description of the test",
        "test_label" => "California Assessment of Student Performance and Progress (CAASPP)",
        "test_source" => "CA Dept. of Education"
      }
    }}.to_json)
    updated Time.now
  end

  factory :ca_cst_10th_grade_science_2015, class: SchoolCache do
    name 'test_scores'
    sequence(:school_id) { |n| n }
    state 'ca'
    value ({
    "18" => {
      "All" => {
        "grades" => {
          "10" => {
            "label" => "School-wide",
            "level_code" => {
              "e,m,h" => {
                "Science" => {
                  "2015" => {
                      "number_students_tested" => 600,
                      "score" => 99.9,
                      "state_average" => 98.1
                  }
                }
              }
            }
          }
        },
        "lowest_grade" => 0,
        "test_description" => "A description of the test",
        "test_label" => "California Standards Test",
        "test_source" => "CA Dept. of Education"
      }
    }}.to_json)
    updated Time.now
  end

  factory :ca_caaspp_schoolwide_ela_2014and2015, class: SchoolCache do
    name 'test_scores'
    sequence(:school_id) { |n| n }
    state 'ca'
    value ({
    "236" => {
      "All" => {
        "grades" => {
          "All" => {
            "label" => "School-wide",
            "level_code" => {
              "e,m,h" => {
                "English Language Arts" => {
                  "2014" => {
                      "number_students_tested" => 114,
                      "score" => 14.3,
                      "state_average" => 28.6
                  },
                  "2015" => {
                      "number_students_tested" => 115,
                      "score" => 15.3,
                      "state_average" => 30.6
                  }
                }
              }
            }
          }
        },
        "lowest_grade" => 0,
        "test_description" => "A description of the test",
        "test_label" => "California Assessment of Student Performance and Progress (CAASPP)",
        "test_source" => "CA Dept. of Education"
      }
    }}.to_json)
    updated Time.now
  end

  factory :ca_caaspp_schoolwide_4subjects_2015, class: SchoolCache do
    name 'test_scores'
    sequence(:school_id) { |n| n }
    state 'ca'
    value ({
    "236" => {
      "All" => {
        "grades" => {
          "All" => {
            "label" => "School-wide",
            "level_code" => {
              "e,m,h" => {
                "English Language Arts" => {
                  "2015" => {
                      "number_students_tested" => 500,
                      "score" => 1,
                      "state_average" => 10
                  }
                },
                "Math" => {
                  "2015" => {
                      "number_students_tested" => 500,
                      "score" => 2,
                      "state_average" => 20
                  }
                },
                "Science" => {
                  "2015" => {
                      "number_students_tested" => 500,
                      "score" => 3,
                      "state_average" => 30
                  }
                },
                "Reading" => {
                  "2015" => {
                      "number_students_tested" => 500,
                      "score" => 4,
                      "state_average" => 40
                  }
                }
              }
            }
          }
        },
        "lowest_grade" => 0,
        "test_description" => "A description of the test",
        "test_label" => "California Assessment of Student Performance and Progress (CAASPP)",
        "test_source" => "CA Dept. of Education"
      }
    }}.to_json)
    updated Time.now
  end

  factory :graduation_rate, class: SchoolCache do
    name 'metrics'
    sequence(:school_id) { |n| n }
    state 'ca'
    value (
    {
      "4-year high school graduation rate" => [
        {
          "breakdown" => "All students",
          "school_value" => 80.6,
          "state_average" => 42,
          'source' => 'CA Dept. of Education'
        }
      ]
    }.to_json)
    updated Time.now
  end

  factory :custom_metrics_all_students_cache, class: SchoolCache do
    transient do
      data_type 'data type'
      school_value 0.0
      state_average 0.0
      source 'CA Dept. of Education'
    end
    before(:create) do |data, evaluator|
      data.value = (
      {
        evaluator.data_type => [
          {
            "breakdown" => "All students",
            "school_value" => evaluator.school_value,
            "state_average" => evaluator.state_average,
            'source' => evaluator.source
          }
        ]
      }.to_json)
    end
    name 'metrics'
    sequence(:school_id) { |n| n }
    state 'ca'
  end

  factory :cached_reviews_info, class: SchoolCache do
    name 'reviews_snapshot'
    sequence(:school_id) { |n| n }
    state 'ca'
    value ({
      'num_reviews' => 348381,
      'num_ratings' => 109991,
      'avg_star_rating' => 4
    }.to_json)
    updated Time.now
  end

  factory :school_cache_esp_responses, class: SchoolCache do
    name 'esp_responses'
    sequence(:school_id) { |n| n }
    state 'CA'
    value ({
      'ap_classes' => {
        'latin' => {
          "member_id" => 1,
          "source" => "osp",
          "created" => Time.now
        },
        'japanese' => {
          "member_id" => 1,
          "source" => "osp",
          "created" => Time.now
        }
      },
      'boys_sports' => {
        'soccer' => {
          "member_id" => 1,
          "source" => "osp",
          "created" => Time.now
        },
        'swimming' => {
          "member_id" => 1,
          "source" => "osp",
          "created" => Time.now
        }
      }
    }.to_json)
    updated Time.now
  end

  factory :school_cache_odd_formatted_esp_responses, class: SchoolCache do
    name 'esp_responses'
    sequence(:school_id) { |n| n }
    state 'CA'
    value ({
      'before_after_care' => {
        'Before' => {
          "member_id" => 1,
          "source" => "osp",
          "created" => Time.now
        },
        'AFTER' => {
          "member_id" => 1,
          "source" => "osp",
          "created" => Time.now
        }
      },
      'boys_sports' => {
        'SocceR' => {
          "member_id" => 1,
          "source" => "osp",
          "created" => Time.now
        },
        'BASEBALL' => {
          "member_id" => 1,
          "source" => "osp",
          "created" => Time.now
        }
      },
      'transportation' => {
        'None' => {
          "member_id" => 1,
          "source" => "osp",
          "created" => Time.now
        }
      },
      'dress_code' => {
        'No_Dress_Code' => {
          "member_id" => 1,
          "source" => "osp",
          "created" => Time.now
        }
      }
    }.to_json)
    updated Time.now
  end


  factory :school_metrics_responses, class: SchoolCache do
    name 'metrics'
    sequence(:school_id) { |n| n }
    state 'CA'
    value ({
      'Enrollment' => [
        "year" => 2012,
        "source" => "NCES",
        "school_value" => 1200.0,
        "district_average" => 3803.0,
        "created" => "2014-05-02T08:42:51-07:00"
      ],
      'Ethnicity' => [
        {
          "year" => 2014,
          "source" => "CA Dept. of Education",
          "breakdown" => "Multiracial",
          "school_value" => 34.5178,
          "created" => "2014-07-25T10:33:24-07:00"
        },
      ],
      'Graduation Rate' => [
        {
          "year" => 2013,
          "breakdown" => "Multiracial",
          "school_value" => 100.0,
          "state_average" => 84.47,
          "created" => "2014-11-13T12:51:46-08:00",
          "performance_level" => "above_average"
        },
        {
          "year" => 2013,
          "breakdown" => "All students",
          "school_value" => 87.0,
          "state_average" => 84.47,
          "created" => "2014-11-13T12:51:46-08:00",
          "performance_level" => "above_average"
        }
      ],
      'Percent of students who meet UC/CSU entrance requirements' => [
        {
          "year" => 2014,
          "source" => "CA Dept. of Education",
          "breakdown" => "Hispanic",
          "school_value" => 72.3404,
          "state_average" => 70.8682,
          "created" => "2015-09-04T14:43:16-07:00",
          "performance_level" => "above_average"
        },
        {
          "year" => 2014,
          "source" => "CA Dept. of Education",
          "breakdown" => "White",
          "school_value" => 62.8319,
          "state_average" => 48.6964,
          "created" => "2015-09-04T14:43:16-07:00",
          "performance_level" => "above_average"
        },
      ],
      '4-year high school graduation rate' => [
        {
          "year" => 2013,
          "source" => "CA Dept. of Education",
          "breakdown" => "Pacific Islander",
          "school_value" => 100.0,
          "state_average" => 78.35,
          "created" => "2014-11-13T12:51:44-08:00",
          "performance_level" => "above_average"
        },
        {
          "year" => 2013,
          "source" => "CA Dept. of Education",
          "breakdown" => "Hispanic",
          "school_value" => 100.0,
          "state_average" => 84.47,
          "created" => "2014-11-13T12:51:44-08:00",
          "performance_level" => "above_average"
        },
      ],
    }.to_json)
    updated Time.now
  end

  factory :cached_ethnicity_data, class: SchoolCache do
    name 'metrics'
    sequence(:school_id) { |n| n }
    state 'CA'
    value ({
      'Ethnicity' => [{
        "breakdown" => "White",
        "created" => "2014-05-02T09:55:10-07:00",
        "district_average" => 78.0,
        "school_value" => 81.3688,
        "source" => "NCES",
        "state_average" => 65.0,
        "year" => 2012
      }]
    }.to_json)
    updated Time.now
  end

  factory :nearby_schools, class: SchoolCache do
    name :nearby_schools
    school_id 1
    state 'CA'
    value ({
        "closest_schools" => [
          {"city" => "Oakland","distance" => 1.50340,"gs_rating" => "3","id" => 17573,"level" => "9-12","methodology" => "closest_schools","name" => "Arise High School","school_media" => nil, "state" => "CA","type" => "Public charter"}
        ],
        "closest_top_then_top_nearby_schools" => [
          {"city" => "Alameda","distance" => 2.06758,"gs_rating" => "10","id" => 14052,"level" => "9-12","methodology" => "closest_top_schools","name" => "Alameda Science And Technology Institute","school_media" => nil, "state" => "CA","type" => "Public district"},
          {"city" => "Oakland","distance" => 2.66094,"gs_rating" => "10","id" => 17494,"level" => "9-12","methodology" => "top_nearby_schools","name" => "Oakland Charter High School","school_media" => nil, "state" => "CA","type" => "Public charter"}
        ]
      }.to_json
    )
    updated Time.now
  end
end
