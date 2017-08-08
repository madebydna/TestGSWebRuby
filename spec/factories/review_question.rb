FactoryGirl.define do

  factory :review_question, class: ReviewQuestion do
    sequence(:id) { |n| n }
    association :review_topic, factory: :review_topic, strategy: :build
    question 'Tell parents a message about the food at this schools'
    principal_question 'Tell me about food'
    responses 'dislike like love'
    layout 'checkbox'
    active 1
    school_type 'public,private,charter'
    school_level 'p,e,m,h'

    factory :overall_rating_question do
      association :review_topic, factory: :overall_topic, strategy: :build
      question 'How would you rate your experience at this school?'
      principal_question 'Please share an overall message with parents and community members who are learning about your school.'
      responses '1,2,3,4,5'
      layout 'overall_stars'
    end

    factory :teacher_question do
      association :review_topic, factory: :teachers_topic, strategy: :build
      question 'Teachers at this school are effective:'
      principal_question 'Teachers at this school are effective:'
      responses 'Strongly disagree,Disagree,Neutral,Agree,Strongly agree'
      layout 'radio_button'
    end

    factory :homework_question do
      association :review_topic, factory: :homework_topic, strategy: :build
      question 'This school has an effective approach to homework:'
      principal_question 'This school has an effective approach to homework:'
      responses 'Strongly disagree,Disagree,Neutral,Agree,Strongly agree'
      layout 'radio_button'
    end

  end
end
