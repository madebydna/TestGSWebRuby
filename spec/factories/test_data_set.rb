FactoryGirl.define do
  TestDataSet.switch_connection_to(:ca)
  TestDataSchoolValue.switch_connection_to(:ca)
  TestDataStateValue.switch_connection_to(:ca)

  factory :test_data_school_value, class: TestDataSchoolValue do
    active 1
    sequence(:number_tested)
    sequence(:value_float)
    sequence(:school_id)

    test_data_set
  end

  factory :test_data_state_value, class: TestDataStateValue do
    active 1
    sequence(:number_tested)
    sequence(:value_float)

    test_data_set
  end

  factory :test_data_set, class: TestDataSet do
    data_type_id 1
    breakdown_id 1
    display_target 'desktop'
    proficiency_band_id nil
    subject_id 1
    year 2013

    factory :test_data_school_values do
      after(:create) do |test_data_set|
        FactoryGirl.build_list(:test_data_school_value, 3, test_data_set: test_data_set)
        FactoryGirl.build(:test_data_state_value, test_data_set: test_data_set)
        test_data_set.reload
      end
    end
  end

end