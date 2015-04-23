FactoryGirl.define do

  factory :review, class: Review do
    sequence(:id) { |n| n }
    association :user, factory: :verified_user, strategy: :build
    association :question, factory: :review_question, strategy: :build
    state 'CA'
    active 1
    comment 'this is a valid comments value since it contains 15 words - including the hyphen'

    # factory :five_star_review do
    #   association :question, factory: :five_star_rating_question, strategy: :build
    #   [:build, :build_stubbed, :create].each do |strategy|
    #     after(strategy) do |review, evaluator|
    #       strategy = :build_stubbed if strategy == :stub
    #       answer = evaluator[:answer] || send(strategy, :review_answer, answer_value: (1..5).to_a.shuffle.first )
    #       review.review_answers << answer
    #       review.save if strategy == :create
    #     end
    #   end
    # end
    #
    # factory :teacher_effectiveness_review do
    #   association :question, factory: :teacher_question, strategy: :build
    #   [:build, :stub, :create].each do |strategy|
    #     after(strategy) do |review, evaluator|
    #       strategy = :build_stubbed if strategy == :stub
    #       answer = evaluator[:answer] || send(
    #         strategy,
    #         :review_answer,
    #         answer_value: 'Very ineffective,Ineffective,Moderately effective,Effective,Very effective'.
    #           split(',').
    #           shuffle.
    #           first
    #       )
    #       require 'pry'; binding.pry
    #       review.review_answers << answer
    #       review.save if strategy == :create
    #     end
    #   end
    # end

    [:build, :build_stubbed, :create].each do |strategy|
      after(strategy) do |review, evaluator|
        strategy = :build_stubbed if strategy == :stub
        # build/create associated school
        s = evaluator.school || send(strategy, :school)
        s.id = evaluator.school_id || review.school_id || s.id
        s.state = evaluator.state || review.state || s.state
        review.school = s
        review.save if strategy == :create

        # ...
      end
    end

    trait :flagged do
      after(:create) do |review, evaluator|
        FactoryGirl.create(
          :review_flag,
          review: review,
          user: review.user
        )
      end
    end

    trait :provisional_review do
      association :user, factory: :new_user, strategy: :build
    end

  end
end
