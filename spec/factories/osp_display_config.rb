FactoryGirl.define do
  factory :osp_display_config do
    sequence   :id
    sequence   :location_group_id
    sequence   :osp_question_id
    sequence   :osp_question_group_id
    sequence   :order_on_page
    sequence   :order_in_group
    page_name  'basic_information'
    active     true
    updated    Time.now
    config     ({ "answers"=> 
                 {
                   "math"=>"math", 
                   "english"=>"c",
                   "career and technology"=>"d"
                 }
               }.to_json)

  end

end
