FactoryGirl.define do
  factory :osp_question do
    sequence(:id) { |n| n }
    sequence(:esp_response_key) { |n| "test+#{n}Key" }
    sequence(:question_label) { |n| "test+#{n} Label" }
    question_type 'multi_select'
    school_type 'public'
    level_code 'p,e,m,h'
    active     true
    updated    Time.now
    default_config  ({ "answers"=> 
                      {
                        "math"=>"math", 
                        "english"=>"c",
                        "career and technology"=>"d"
                      }
                    }.to_json)

    trait :with_osp_display_config do
      ignore do
        osp_question_group_id  1
        order_on_page          1
        order_in_group         1
        page_name              'basic_information'
        active                 true
        config                 ({ "answers" =>
                                 {
                                   "math" => "math",
                                   "english" => "c",
                                   "career and technology" => "d"
                                 }
                               }.to_json)
      end

      after(:create) do |osp_question, evaluator|
        FactoryGirl.create(:osp_display_config, 
          osp_question_id: osp_question.id,
          osp_question_group_id: evaluator.osp_question_group_id,
          order_on_page: evaluator.order_on_page,
          order_in_group: evaluator.order_in_group,
          active: evaluator.active,
          page_name: evaluator.page_name,
          config: evaluator.config
        )
      end
    end

  end

end
