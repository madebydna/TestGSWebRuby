FactoryGirl.define do

  factory :review_question, class: ReviewQuestion do
    sequence(:id) { |n| n }
    association :review_topic, factory: :review_topic, strategy: :build
    question 'How do you feel about the food?'
    responses 'dislike like love'
    layout 'checkbox'
    active 1
    school_type 'public,private,charter'
    school_level 'p,e,m,h'

  end
end
