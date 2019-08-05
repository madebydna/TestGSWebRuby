FactoryGirl.define do
  factory :data_type, class: Omni::DataType do
    name 'foo'

    trait :with_tags do
      ignore do
        tag nil
      end

      after(:create) do |data_type, evaluator|
        create(:data_type_tag, data_type: data_type, tag: evaluator.tag)
      end
    end

    trait :with_feeds_data_set do
      ignore { state nil }

      after(:create) do |data_type, evaluator|
        create(:data_set, :feeds, data_type: data_type, state: evaluator.state)
      end
    end

    trait :with_data_set do
      ignore { state nil }

      after(:create) do |data_type, evaluator|
        create(:data_set, :none, data_type: data_type, state: evaluator.state)
      end
    end

  end
end
