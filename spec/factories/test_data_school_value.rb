FactoryGirl.define do
  TestDataSchoolValue.switch_connection_to(:ca)

  factory :test_data_school_value, class: TestDataSchoolValue do
    active 1
    number_tested 2
    school_id 2
    value_float 1
    value_text '1'
    data_set_id 1
  end

end