FactoryGirl.define do
  factory :esp_response do
    sequence(:id) { |n| n }
    association :school, factory: :school, strategy: :build
    association :user, factory: :user, strategy: :build
    response_key 'a_key'
    response_value 'a value'
    esp_source 'osp'
    active 1
    created Time.zone.now

    before(:create) do |esp_response, evaluator|
      user = FactoryGirl.create(:user)
      esp_response.user = user
    end
  end


end