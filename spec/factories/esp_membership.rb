FactoryGirl.define do

  factory :esp_membership, class: EspMembership do
    member_id :member_id
    school_id 1
    state 'ca'
    created Time.new
    updated Time.new
    job_title 'someone awesome'
  end

  trait :with_approved_status do
    status 'approved'
    active 1
  end

  trait :with_provisional_status do
    status 'provisional'
    active 0
  end

end