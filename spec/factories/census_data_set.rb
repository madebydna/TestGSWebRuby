FactoryGirl.define do
  CensusDataSet.switch_connection_to(:ca)
  factory :ethnicity_data_set, :class => 'CensusDataSet' do
    #sequence(:id) { |n| "some-title-#{n}" }
    data_type_id 9
    year 2011
    active 1
    level_code 'e,m,h'
    grade '9'
  end

  factory :enrollment_data_set, :class => 'CensusDataSet' do
    #sequence(:id) { |n| "some-title-#{n}" }
    data_type_id 17
    year 2011
    active 1
    level_code 'e,m,h'
    grade '9'
  end
end