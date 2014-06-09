FactoryGirl.define do
  TestDataSet.switch_connection_to(:ca)

  factory :ratings_test_data_set, class: TestDataSet do
    data_type_id :data_type_id
    breakdown_id 1
    display_target 'ratings'
    proficiency_band_id nil
    subject_id 1
    year 2013
    active 1
    test_data_school_values {
      FactoryGirl.build_list(:test_data_school_value, 1)
    }
  end

  factory :test_data_set, class: TestDataSet do
    data_type_id :data_type_id
    display_target :display_target
    breakdown_id 1
    proficiency_band_id nil
    subject_id 1
    year 2013
    active 1
    sequence(:id)
  end

  trait :with_school_values do
    ignore do
      school_id 2
      value_text '1'
      value_float 1
    end

    after(:create) do |data_set, evaluator|
      FactoryGirl.create_list(:test_data_school_value,1, data_set_id: data_set.id, school_id: evaluator.school_id,
                              value_text: evaluator.value_text, value_float: evaluator.value_float)
    end
  end


end