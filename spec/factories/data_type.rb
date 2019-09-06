FactoryBot.define do
  factory :data_type, class: Omni::DataType do
    name 'foo'

    trait :with_tags do
      transient do
        tag nil
      end

      after(:create) do |data_type, evaluator|
        create(:data_type_tag, data_type: data_type, tag: evaluator.tag)
      end
    end

    trait :with_feeds_data_set do
      transient do 
        state { nil }
        date_valid { Date.today }
      end

      after(:create) do |data_type, evaluator|
        create(:data_set, :feeds, data_type: data_type, state: evaluator.state, date_valid: evaluator.date_valid)
      end
    end

    trait :with_data_set do
      transient { state nil }

      after(:create) do |data_type, evaluator|
        create(:data_set, :none, data_type: data_type, state: evaluator.state)
      end
    end

  end
end
