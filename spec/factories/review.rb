FactoryGirl.define do

  factory :review, class: Review do
    sequence(:id) { |n| n }
    association :user, factory: :verified_user, strategy: :build
    association :question, factory: :review_question, strategy: :build
    state 'CA'
    active 1
    comment 'this is a valid comments value since it contains 15 words - including the hyphen'

    factory :five_star_review do

      ignore do
        answer_value (1..5).to_a.shuffle.first
      end

      association :question, factory: :overall_rating_question, strategy: :build

      [:build, :build_stubbed, :create].each do |strategy|
        after(strategy) do |review, evaluator|
          # http://stackoverflow.com/questions/17754770/factorygirl-build-stubbed-strategy-with-a-has-many-association
          # We should create our own factory methods when we need factory objects to be prepopulated with associated
          # objects. But adding this hack now since we don't have time to do that now
          #
          # If the review has an ID, then ActiveRecord will go to the DB to get ReviewAnswers, or will try to save
          # them when adding to review_answers collection on the Review
          unless strategy == :create
            id = review.id
            review.id = nil
          end
          strategy = :build_stubbed if strategy == :stub
          answer_value = evaluator.answer_value
          answer = evaluator[:answer] || send(strategy, :review_answer, review: review, answer_value: answer_value )
          review.answers << answer
          answer.review = review

          # Add back the ID that the factory generated
          unless strategy == :create
            review.id = id
          end
        end
      end
    end

    factory :teacher_effectiveness_review do
      ignore do
        answer_value 'Very ineffective,Ineffective,Moderately effective,Effective,Very effective'.
              split(',').
              shuffle.
              first
      end
      association :question, factory: :teacher_question, strategy: :build
      [:build, :stub, :create].each do |strategy|
        after(strategy) do |review, evaluator|
          # http://stackoverflow.com/questions/17754770/factorygirl-build-stubbed-strategy-with-a-has-many-association
          unless strategy == :create
            id = review.id
            review.id = nil
          end
          strategy = :build_stubbed if strategy == :stub
          answer_value = evaluator.answer_value
          answer = evaluator[:answer] || send(
            strategy,
            :review_answer,
            review: review,
            answer_value: answer_value
          )
          review.answers << answer
          unless strategy == :create
            review.id = id
          end
        end
      end
    end

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
