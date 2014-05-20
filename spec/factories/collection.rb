FactoryGirl.define do
  # usage: 
  # FactoryGirl.build(
  #   :collection,
  #   collection_id: 100,
  #   state: 'ca',
  #   city: 'alameda'
  # )
  # or better yet don't depend on specific collction_id (production code 
  # shouldn't hardcode collection id)
  #
  # FactoryGirl.build(
  #   :collection,
  #   state: 'ca',
  #   city: 'alameda'
  # )
  # 
  # You can use other options as well
  # FactoryGirl.build(
  #   :collection,
  #   state: 'ca',
  #   city: 'alameda',
  #   options: {
  #     hasStateChoosePage: true
  #   }
  # )
  factory :collection, class: Collection do

    ignore do
      sequence(:id) { |n| n }
      city 'detroit'
      state 'mi'
      options({})
    end

    name 'a name'

    hub_city_mapping do
      params = {
        collection_id: id,
        city: city,
        state: state,
        active: 1
      }.merge(options)

      FactoryGirl.build(
        :hub_city_mapping,
        params
      )
    end
  end

  factory :detroit_collection, parent: :collection do
    city 'detroit'
    state 'mi'
  end
end

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
    state 'indiana'
    active 1
  end
end
