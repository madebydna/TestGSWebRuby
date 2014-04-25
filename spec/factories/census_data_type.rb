FactoryGirl.define do

  factory :census_data_type, class: CensusDataType do
    sequence(:id)
    description 'a description'
    type 'num'
  end
  
end