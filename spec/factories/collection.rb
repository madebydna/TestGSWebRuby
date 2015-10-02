FactoryGirl.define do
  factory :collection, class: Collection do

    ignore do
      sequence(:id) { |n| n }
      city 'detroit'
      state 'mi'
      options({})
    end

    name 'a name'
    definition '{}'

    trait :with_hub_city_mapping do
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
  end
end
