FactoryGirl.define do
  TestDataSet.switch_connection_to(:ca)

  factory :test_data_set_for_state_ratings, class: TestDataSet do
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

  factory :test_data_set_for_city_ratings, class: TestDataSet do
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

  factory :test_data_set_for_preK_ratings, class: TestDataSet do
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

end