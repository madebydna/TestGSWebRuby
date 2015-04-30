FactoryGirl.define do

  factory :review_topic, class: ReviewTopic do
    sequence(:id) { |n| n }
    name 'Nutrition'
    school_type 'public,private,charter'
    school_level 'p,e,m,h'

    factory :overall_topic do
      name 'Overall'
    end

    factory :teachers_topic do
      name 'Teachers'
    end

    factory :honesty_topic do
      name 'Honesty'
    end

    factory :empathy_topic do
      name 'Empathy'
    end

    factory :homework_do do
      name 'Homework'
    end
  end

end
