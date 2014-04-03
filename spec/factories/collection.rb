FactoryGirl.define do
  factory :collection, class: Collection do
    name 'a name'
    hub_city_mapping { FactoryGirl.build(:hub_city_mapping) }
  end
end

FactoryGirl.define do
  factory :hub_city_mapping, class: HubCityMapping do
    collection_id 1
    city 'detroit'
    state 'mi'
    active 1
  end

  factory :state_hub_mapping, class: HubCityMapping do
    collection_id 6
    city ''
    state 'indiana'
    active 1
  end
end
