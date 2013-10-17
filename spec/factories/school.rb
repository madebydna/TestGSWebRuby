FactoryGirl.define do
    factory :school do
      state 'CA'
      school_metadatas {
        Array(2..4).sample.times.map do
          FactoryGirl.build(:school_metadata)
        end
      }
    end
end