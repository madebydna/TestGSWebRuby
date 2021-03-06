FactoryGirl.define do
  factory :display_range do
    sequence(:id) { |n| n }
    state nil
    data_type 'census'
    data_type_id 1
    subject_id nil
    year nil
    ranges ({'below_average_cap' => 30,
      'average_cap' => 60,
      'above_average_cap' => 101
    }).to_json
  end
end
