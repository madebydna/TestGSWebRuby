FactoryGirl.define do
  factory :osp_question do
    sequence(:id) { |n| n }
    sequence(:esp_response_key) { |n| "test+#{n}Key" }
    sequence(:question_label) { |n| "test+#{n} Label" }
    question_type 'multi_select'
    school_type 'public'
    level_code 'p,e,m,h'
    active     true

  end

end
