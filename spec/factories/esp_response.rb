FactoryBot.define do
  factory :esp_response do
    sequence(:id) { |n| n }
    association :school, factory: :school, strategy: :build
    association :user, factory: :user, strategy: :build
    response_key 'a_key'
    sequence(:response_value) { |n| "#{n} value"}
    esp_source 'osp'
    active 1
    created Time.zone.now

    before(:create) do |esp_response, evaluator|
      user = FactoryBot.create(:user)
      esp_response.user = user
    end
  end


end
