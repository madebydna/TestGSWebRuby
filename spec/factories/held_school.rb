FactoryBot.define do

  factory :held_school, class: HeldSchool do
    sequence(:id) { |n| n }
    school_id 1
    state 'CA'
    notes 'foo'
    active 1
  end

end
