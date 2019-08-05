FactoryGirl.define do
  factory :data_type, class: Omni::DataType do
    name 'foo'

    trait :with_tags do
      after(:create) do |data_type|
        create(:data_type_tag, data_type: data_type, tag: Omni::TestDataValue::TAGS.first)
      end
    end

  end
end
