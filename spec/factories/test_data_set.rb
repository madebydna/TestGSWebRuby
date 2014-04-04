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

end