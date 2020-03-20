FactoryBot.define do
  factory :metric, class: Omni::Metric do
    association :breakdown, factory: [:breakdown, :with_tags]
    association :data_set
    association :subject
    entity_type { 'school' }
    gs_id { 1 }
    value { 3.44 }
    grade { 'NA' }
    active { 1 }
  end
end