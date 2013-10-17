FactoryGirl.define do
  factory :school_metadata do
    meta_key 'overallRating'
    meta_value { 1 + rand(10) }
  end
end