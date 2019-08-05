FactoryGirl.define do
  factory :test_data_value, class: Omni::TestDataValue do
    proficiency_band
    entity_type Omni::TestDataValue::SCHOOL_ENTITY
  end
end
