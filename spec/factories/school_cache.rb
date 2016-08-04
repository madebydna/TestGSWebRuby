FactoryGirl.define do
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
  end

  factory :cached_gs_rating, class: SchoolCache do
    name 'ratings'
    sequence(:school_id) { |n| n }
    state 'ca'
    value ([
      {
        'data_type_id' => 174,
        'year' => 2014,
        'school_value_text' => nil,
        'school_value_float' => 5.0,
        'name' => 'GreatSchools rating'
      }
    ].to_json)
    updated Time.now
  end

  factory :cached_enrollment, class: SchoolCache do
    name 'characteristics'
    sequence(:school_id) { |n| n }
    state 'ca'
    value ({
      'Enrollment' => [
        "year" => 2012,
        "source" => "NCES",
        "school_value" => 1200.0,
        "district_average" => 3803.0,
        "created" => "2014-05-02T08:42:51-07:00"
      ]
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


  factory :school_characteristic_responses, class: SchoolCache do
    name 'characteristics'
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
          "original_breakdown" => "Hispanic",
          "school_value" => 72.3404,
          "state_average" => 70.8682,
          "created" => "2015-09-04T14:43:16-07:00",
          "performance_level" => "above_average",
          "school_value_2013" => 71.3592,
          "state_average_2013" => 67.7065,
          "school_value_2014" => 72.3404,
          "state_average_2014" => 70.8682
        },
        {
          "year" => 2014,
          "source" => "CA Dept. of Education",
          "breakdown" => "White",
          "original_breakdown" => "White",
          "school_value" => 62.8319,
          "state_average" => 48.6964,
          "created" => "2015-09-04T14:43:16-07:00",
          "performance_level" => "above_average",
          "school_value_2014" => 62.8319,
          "state_average_2014" => 48.6964,
          "school_value_2013" => 62.1622,
          "state_average_2013" => 47.1071
        },
      ],
      '4-year high school graduation rate' => [
        {
          "year" => 2013,
          "source" => "CA Dept. of Education",
          "breakdown" => "Pacific Islander",
          "original_breakdown" => "Pacific Islander",
          "school_value" => 100.0,
          "state_average" => 78.35,
          "created" => "2014-11-13T12:51:44-08:00",
          "performance_level" => "above_average",
          "school_value_2012" => 100.0,
          "state_average_2012" => 76.97,
          "school_value_2011" => 100.0,
          "state_average_2011" => 74.89,
          "school_value_2013" => 100.0,
          "state_average_2013" => 78.35
        },
        {
          "year" => 2013,
          "source" => "CA Dept. of Education",
          "breakdown" => "Hispanic",
          "original_breakdown" => "Hispanic",
          "school_value" => 100.0,
          "state_average" => 84.47,
          "created" => "2014-11-13T12:51:44-08:00",
          "performance_level" => "above_average",
          "school_value_2012" => 100.0,
          "state_average_2012" => 83.96,
          "school_value_2011" => 100.0,
          "state_average_2011" => 81.85,
          "school_value_2013" => 100.0,
          "state_average_2013" => 84.47
        },
      ],
    }.to_json)
    updated Time.now
  end






end
