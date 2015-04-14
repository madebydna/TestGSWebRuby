FactoryGirl.define do

  factory :reported_entity, class: ReportedEntity do
    sequence(:id) { |n| n }
    association :user, factory: :user, strategy: :build
    association :school_rating, factory: :school_rating, strategy: :build
    sequence(:reported_entity_id) { |n| n }
    active true
    created { Time.zone.now }


    factory :old_reported_review do
      reported_entity_type 'schoolReview'
    end
  end


end