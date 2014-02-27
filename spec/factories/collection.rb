FactoryGirl.define do
  factory :collection, class: Collection do
    name 'a name'
    hub_city_mapping { FactoryGirl.build(:hub_city_mapping) }
  end
end

FactoryGirl.define do
  factory :hub_city_mapping, class: HubCityMapping do
    collection_id 1
    city 'alameda'
    state 'ca'
    active 1
  end
end