FactoryGirl.define do
  factory :data_type, class: Omni::DataType do
    name 'foo'

    ignore do
      tag nil
    end

    factory :data_type_with_tags do
      after(:create) do |data_type, evaluator|
        create(:data_type_tag, data_type: data_type, tag: evaluator.tag)
      end
    end
  end
end
