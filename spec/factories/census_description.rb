FactoryGirl.define do

  factory :census_description, class: CensusDescription do
    sequence(:id)
    census_data_set_id 1
    state 'ca'
    school_type 'public'
    source 'test source 1'
    description 'test description'
  end

end