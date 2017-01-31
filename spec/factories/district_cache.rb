FactoryGirl.define do
  factory :district_cache, class: DistrictCache do
    name :name
    district_id :district_id
    state :state
    value :value
    updated Time.now
  end

  factory :cached_district_ratings, class: DistrictCache do
    name 'ratings'
    sequence(:district_id) { |n| n }
    state 'ca'
    value :value
    updated Time.now

    trait :with_gs_rating do
      ignore do
        gs_rating_value 5.0
      end
      before(:create) do |cached_ratings, evaluator|
        cached_ratings.value = [
          {
            'data_type_id' => 174,
            'year' => 2014,
            'value_text' => nil,
            'value_float' => evaluator.gs_rating_value,
            'name' => 'GreatSchools rating'
          }
        ].to_json
      end
    end
  end

  factory :cached_district_schools_summary, class: DistrictCache do
    name 'district_schools_summary'
    sequence(:district_id) { |n| n }
    state 'ca'
    value ({
      'school counts by level code' => {
        "e" => 16,
        "m" => 11,
        "h" => 8
      }
    }.to_json)
    updated Time.now
  end

end
