FactoryBot.define do
  factory :api_plan, class: Api::Plan do
    name { 'free_trial' }
    price { 0.0 }
    calls { 1000 }
  end
end

