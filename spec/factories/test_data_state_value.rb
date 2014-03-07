FactoryGirl.define do
  TestDataStateValue.switch_connection_to(:ca)

  factory :test_data_state_value, class: TestDataStateValue do
    active 1
    sequence(:number_tested)
    sequence(:value_float)

    test_data_set
  end
end