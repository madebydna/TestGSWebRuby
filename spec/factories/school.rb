FactoryGirl.define do
    sequence :id do |n|
      n
    end

    factory :school do
      id
      name 'Alameda High School'
      city 'alameda'
      state 'CA'
      school_metadatas {
        Array(2..4).sample.times.map do
          FactoryGirl.build(:school_metadata)
        end
      }
      collections { FactoryGirl.build_list :collection, 1 }
      created { Time.now.to_s }
    end
end