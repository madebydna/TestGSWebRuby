FactoryGirl.define do
  factory :source, class: Omni::Source do
    sequence(:name) { |n| n }
  end
end
