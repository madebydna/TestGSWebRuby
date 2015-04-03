FactoryGirl.define do

  factory :review, class: Review do
    sequence(:id) { |n| n }
    association :school, factory: :school, strategy: :build
    association :user, factory: :user, strategy: :build
    association :question, factory: :review_question, strategy: :build
    state 'CA'
    active 1
    comment 'this is a valid comments value since it contains 15 words - including the hyphen'
    user_type 'parent'

  end
end
