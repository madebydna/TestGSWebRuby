FactoryGirl.define do
  factory :breakdown, class: Omni::Breakdown do
    sequence(:name) { |n| n }

    trait :with_tags do
      after(:create) do |breakdown|
        create(:breakdown_tag, breakdown: breakdown)
      end
    end
  end
end
