FactoryGirl.define do

  factory :school_note, class: SchoolNote do
    sequence(:id) { |n| n }
    list_member_id 0
    school_id 1
    state 'CA'
    notes 'foo'
  end

end