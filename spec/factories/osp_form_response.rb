FactoryGirl.define do
  factory :osp_form_response do
    sequence :id do |n|
      n
    end
    esp_membership_id 1
    response { 'canoe' }.to_json #implement later
    osp_question_id 1
    updated Time.now
  end
end
