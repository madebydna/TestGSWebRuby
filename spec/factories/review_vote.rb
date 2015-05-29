FactoryGirl.define do

  factory :review_vote, class: ReviewVote do
    sequence(:id) { |n| n }
    active true
  end
end
