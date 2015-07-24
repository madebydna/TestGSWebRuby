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
      ]
    }.to_json)
    updated Time.now
  end






end
