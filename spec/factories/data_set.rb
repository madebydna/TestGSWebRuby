FactoryGirl.define do
  factory :data_set, class: Omni::DataSet do
    notes "Foo notes"
    state 'CA'
    association :data_type, factory: [:data_type, :with_tags]
    source

    trait(:feeds) { configuration { Omni::DataSet::FEEDS } }
    trait(:web) { configuration { Omni::DataSet::WEB } }

  end

end
