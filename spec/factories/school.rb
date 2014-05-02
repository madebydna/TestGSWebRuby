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
    end

    factory :school_with_params, class: School do
      id :id
      state :state
      city :city ? :city : 'alameda'
    end
end