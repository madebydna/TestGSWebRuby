FactoryGirl.define do
  factory :question_display_config do
    sequence(:id) { |n| n }
    sequence(:location_group_id) {'1' }
    sequence(:osp_question_id) { |n| n}
    active     true

  end

end
