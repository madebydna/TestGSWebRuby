FactoryGirl.define do
  factory :school_cache, class: SchoolCache do
    name :name
    school_id :school_id
    state :state
    value :value
    updated Time.now
  end

  factory :cached_ratings, class: SchoolCache do
    name 'ratings'
    sequence(:school_id) { |n| n }
    state 'ca'
    value :value
    updated Time.now
  end
end