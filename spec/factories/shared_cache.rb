FactoryGirl.define do

  factory :shared_cache do
    quay  'cache_key'
    value '1234'
    expiration Time.parse('7:00')
  end

end
