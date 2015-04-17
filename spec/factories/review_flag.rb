FactoryGirl.define do

  factory :review_flag, class: ReviewFlag do
    sequence(:id) { |n| n }
    review_id 1


  end



end