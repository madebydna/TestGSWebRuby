FactoryBot.define do
  factory :crpe_data, class: 'CRPEData' do
    gs_id { 1 }
    state { 'ca' }
    entity_type { 'district' }
    data_type { 'OVERVIEW' }
    value { 'Some Text' }
    date_valid { Time.now }
    source { 'Greatschools' }
    active { 1 }
  end
end
