FactoryGirl.define do
  factory :data_type, class: Omni::DataType do
    name 'foo'

    factory :data_type_with_tags do
      after(:create) do |data_type|
        create(:data_type_tag, data_type: data_type)
      end
    end
  end
end
