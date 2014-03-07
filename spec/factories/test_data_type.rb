FactoryGirl.define do
  TestDataType.switch_connection_to(:gs_schooldb)

  factory :test_data_type, class: TestDataType do
    id :id
    description 'This test is awesome.'
    display_name 'Awesome Test'
    display_type 'graph'
    name 'awesome test'
    type ''
  end
end
