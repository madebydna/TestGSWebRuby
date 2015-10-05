FactoryGirl.define do
  factory :hub_city_mapping, class: HubCityMapping do
    sequence(:id) { |n| n }
    collection_id 1
    city 'detroit'
    state 'mi'
    active 1
  end

  factory :state_hub_mapping, class: HubCityMapping do
    sequence(:id) { |n| n }
    collection_id 6
    city nil
    state 'in'
    active 1
  end
end
