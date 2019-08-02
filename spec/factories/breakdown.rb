FactoryGirl.define do
  factory :breakdown, class: Omni::Breakdown do
    name 'foo'

    factory :breakdown_with_tags do
      after(:create) do |breakdown|
        create(:breakdown_tag, breakdown: breakdown)
      end
    end
  end
end
