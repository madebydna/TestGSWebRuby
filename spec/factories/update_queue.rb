FactoryGirl.define do
  factory :update_queue_form_response do
    sequence :id do |n|
      n
    end
    source osp
    status done
    update_blob { 'canoe' }.to_json #implement later
    notes nil
    updated Time.now
    priority 2
  end
end
