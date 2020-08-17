FactoryBot.define do
  factory :api_subscription, class: Api::Subscription do
    association :user
    association :plan
  end
end

