FactoryGirl.define do

  factory :review, class: Review do
    sequence(:id) { |n| n }
    association :user, factory: :verified_user, strategy: :build
    association :question, factory: :review_question, strategy: :build
    state 'CA'
    active 1
    comment 'this is a valid comments value since it contains 15 words - including the hyphen'

    after(:build) do |review, evaluator|
      s = evaluator.school || build(:school)
      s.id = evaluator.school_id || review.school_id || s.id
      s.state = evaluator.state || review.state || s.state
      review.school = s
    end

    after(:create) do |review, evaluator|
      s = evaluator.school || create(:school)
      s.id = evaluator.school_id || review.school_id || s.id
      s.state = evaluator.state || review.state || s.state
      review.school = s
    end

    trait :flagged do
      after(:create) do |review, evaluator|
        FactoryGirl.create(
          :reported_review,
          review: review,
          user: review.user
        )
      end
    end
  end
end
