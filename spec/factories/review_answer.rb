FactoryGirl.define do

  factory :review_answer, class: ReviewAnswer do
    sequence(:id) { |n| n }
    association :review, factory: :review, strategy: :build
    value 'dislike'

  end
end