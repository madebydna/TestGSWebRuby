FactoryGirl.define do
  factory :rating, class: Omni::Rating do
    association :breakdown, factory: [:breakdown, :with_tags]
  end
end
