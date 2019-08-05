FactoryGirl.define do
  factory :proficiency_band, class: Omni::ProficiencyBand do
    name 'A proficiency band'
    group_id 1
    group_order 'test'
  end
end
