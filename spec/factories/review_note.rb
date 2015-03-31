FactoryGirl.define do

  factory :review_note, class: ReviewNote do
    sequence(:id) { |n| n }
    list_member_id 0
    review_id 1
    notes 'foo'
  end

end