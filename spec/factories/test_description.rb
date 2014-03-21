FactoryGirl.define do
  TestDescription.switch_connection_to(:gs_schooldb)

  factory :test_description,class: TestDescription do
    data_type_id :data_type_id
    description "This describes the test"
    source "This is the source of test data"
    scale "scale of the test"
    subgroup_description "This describes the test by subgroup"
  end
end
