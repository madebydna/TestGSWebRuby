FactoryGirl.define do

  factory :review_flag, class: ReviewFlag do
    sequence(:id) { |n| n }
    review_id 1
    comment 'This is a comment on the review flag'
    reason 'auto-flagged'
  end

end