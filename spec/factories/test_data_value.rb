FactoryBot.define do
  factory :test_data_value, class: Omni::TestDataValue do
    entity_type Omni::TestDataValue::SCHOOL_ENTITY
    value 1
    association :breakdown, factory: [:breakdown, :with_tags]
    gs_id 1
  end
end
