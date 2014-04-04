FactoryGirl.define do
  factory :city do
    sequence :id do |n|
      n
    end

    name 'Fort Wayne'
    fipsCounty 18003
    state 'IN'
    population 253691
    lat 41.0882
    lon(-85.1439)
    bp_census_id 362355
    active 1
  end
end
