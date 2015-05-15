FactoryGirl.define do

  factory :held_school, class: HeldSchool do
    sequence(:id) { |n| n }
    school_id 1
    state 'CA'
    notes 'foo'
  end

end