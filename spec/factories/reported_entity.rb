FactoryGirl.define do

  factory :reported_review, class: ReportedEntity do
    sequence(:id) { |n| n }
    association :user, factory: :user, strategy: :build
    sequence(:reported_entity_id) { |n| n }
    reported_entity_type 'schoolReview'
  end


end