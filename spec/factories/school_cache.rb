FactoryGirl.define do
  factory :school_cache, class: SchoolCache do
    name :name
    school_id :school_id
    state :state
    value :value
    updated Time.now
  end
end