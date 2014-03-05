FactoryGirl.define do
  TestDataSchoolValue.switch_connection_to(:ca)

  factory :test_data_school_value, class: TestDataSchoolValue do
    active 1
    number_tested 2
    school_id 1
    value_float 1
    value_text '1'
  end

  #factory :test_data_school_value, class: TestDataSchoolValue do
  #  active 1
  #  sequence(:number_tested)
  #  sequence(:value_float)
  #  sequence(:school_id)
  #
  #  test_data_set
  #end

end