FactoryGirl.define do

  factory :reported_review, class: ReportedReview do
    sequence(:id) { |n| n }
    review_id 1
  end

end