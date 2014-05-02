FactoryGirl.define do

  factory :census_description, class: CensusDescription do
    sequence(:id)
    state 'ca'
    school_type 'public'
    source 'test source 1'
    description 'test description'
  end

end