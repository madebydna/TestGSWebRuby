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
end
