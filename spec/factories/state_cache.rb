FactoryBot.define do

  factory :state_cache do
    state 'ca'
    name :name
    value :value
    updated Time.now

    trait :with_school_levels do
      name 'school_levels'
      value {
        {
          "all" => [{"state_value" => 100}],
          "elementary" => [{"state_value" => 30}],
          "middle" => [{"state_value" => 40}],
          "high" => [{"state_value" => 30}]
        }.to_json
      }
    end
  end

end
