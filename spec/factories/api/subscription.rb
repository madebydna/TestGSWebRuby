FactoryBot.define do
  factory :api_subscription, class: Api::Subscription do
    association :user, factory: :api_user
    association :plan, factory: :api_plan
  end
end

