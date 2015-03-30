FactoryGirl.define do

  factory :review_note, class: ReviewNote do
    sequence(:id) { |n| n }
    review_id 1

    trait :active do
      active 1
    end
    trait :inactive do
      active 0
    end
  end

end