FactoryGirl.define do
    sequence :id do |n|
      n
    end

    factory :school do
      id
      name 'Alameda High School'
      city 'alameda'
      state 'CA'
      collections { FactoryGirl.build_list :collection, 1 }
      created { Time.now.to_s }

      factory :alameda_high_school do
        name 'Alameda High School'
        city 'Alameda'
        state 'CA'
        level_code 'h'
        type 'public'
      end

      factory :bay_farm_elementary_school do
        name 'Bay Farm Elementary School'
        city 'Alameda'
        state 'CA'
        level_code 'e'
        type 'public'
      end

      factory :the_friendship_preschool do
        name 'The Friendship Preschool'
        city 'Encinitas'
        state 'CA'
        level_code 'p'
        type 'private'
      end

      factory :emery_secondary do
        name 'Emery Secondary'
        city 'Emeryville'
        state 'CA'
        level_code 'm,h'
        type 'public'
      end

      factory :an_elementary_school do
        name 'Elementary School'
        city 'San Francisco'
        state 'CA'
        level_code 'e'
        type 'public'
      end

      factory :a_prek_elem_middle_high_school do
        name 'All Grade School'
        city 'San Francisco'
        state 'CA'
        level_code 'p,e,m,h'
        type 'private'
      end

      factory :a_high_school do
        name 'High School'
        city 'San Francisco'
        state 'CA'
        level_code 'h'
        type 'private'
      end

      trait :with_hub_city_mapping do
        ignore do
          collection_id 1
        end

        after(:create) do |school, evaluator|
          FactoryGirl.create_list(:hub_city_mapping,1,collection_id: evaluator.collection_id,city: 'san francisco', state:'ca')
        end
      end

    end

    factory :school_with_params, class: School do
      id :id
      state :state
      city :city ? :city : 'alameda'
    end
end