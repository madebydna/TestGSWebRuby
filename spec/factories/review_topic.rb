FactoryGirl.define do

  factory :review_topic, class: ReviewTopic do
    sequence(:id) { |n| n }
    name 'Nutrition'
    active 1
    school_type 'public,private,charter'
    school_level 'p,e,m,h'

  end
end
