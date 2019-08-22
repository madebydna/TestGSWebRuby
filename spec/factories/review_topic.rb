FactoryBot.define do

  factory :review_topic, class: ReviewTopic do
    sequence(:id) { |n| n }
    name 'Nutrition'
    school_type 'public,private,charter'
    school_level 'p,e,m,h'
    label 'Encourages good nutrition'

    factory :overall_topic do
      name 'Overall'
      label 'Overall experience'
    end

    factory :teachers_topic do
      name 'Teachers'
      label 'Teacher effectiveness'
    end

    factory :honesty_topic do
      name 'Honesty'
      label 'Develops honesty'
    end

    factory :empathy_topic do
      name 'Empathy'
      label 'Develops empathy'
    end

    factory :homework_topic do
      name 'Homework'
      label 'Amount of homework'
    end

    factory :gratitude_topic do
      name 'Gratitude'
      label 'Grateful to'
    end

  end

end
