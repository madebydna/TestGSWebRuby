FactoryGirl.define do

  factory :school_rating, class: SchoolRating do
    sequence(:id) { |n| n }
    association :school, factory: :school, strategy: :build
    association :user, factory: :user, strategy: :build
    state 'ca'
    status 'p'
    comments 'this is a valid comments value since it contains 15 words - including the hyphen'
    who 'parent'
    quality '5'
    ip '123.123.123.123'
    
    factory :valid_school_rating, class: SchoolRating do
    end
  end

  factory :unpublished_review, class: SchoolRating, parent: :valid_school_rating do
    status 'u'
  end

end