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
    end

    factory :school_with_params, class: School do
      id :id
      state :state
      city :city ? :city : 'alameda'
    end
end