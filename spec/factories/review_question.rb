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

    factory :overall_rating_question do
      association :review_topic, factory: :overall_topic, strategy: :build
      question 'How would you rate your experience at this school?'
      responses '1,2,3,4,5'
      layout 'overall_stars'
    end

    factory :teacher_question do
      association :review_topic, factory: :teachers_topic, strategy: :build
      question 'How effective are this school\'s teachers at making students successful?'
      responses 'Very ineffective,Ineffective,Moderately effective,Effective,Very effective'
      layout 'radio_button'
    end

    factory :honesty_question do
      association :review_topic, factory: :honesty_topic, strategy: :build
      question 'Do you agree that this school develops honesty / integrity in its students?'
      responses 'Strongly disagree,Moderately disagree,Neither agree nor disagree,Moderately agree,Strongly agree'
      layout 'radio_button'
    end

    factory :empathy_question do
      association :review_topic, factory: :empathy_topic, strategy: :build
      question 'Do you agree that this school develops compassion / caring / empathy in its students?'
      responses 'Strongly disagree,Moderately disagree,Neither agree nor disagree,Moderately agree,Strongly agree'
      layout 'radio_button'
    end

    factory :homework_question do
      association :review_topic, factory: :homework_topic, strategy: :build
      question 'How do you feel about the amount of homework given at this school?'
      responses 'Too much,Just the right amount,Not enough,Don\'t know'
      layout 'radio_button'
    end
  end
end
