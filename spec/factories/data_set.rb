FactoryBot.define do
  factory :data_set, class: Omni::DataSet do
    notes "Foo notes"
    state 'CA'
    source_id 1
    association :data_type

    trait(:none) { configuration { Omni::DataSet::NONE } }
    trait(:web) { configuration { Omni::DataSet::WEB } }
    trait(:feeds) { configuration { Omni::DataSet::FEEDS } }
  end

end
