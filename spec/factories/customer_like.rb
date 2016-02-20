FactoryGirl.define do
  factory :customer_like do
    sequence(:id) { |n| n }
    product_id 1
    user_session_key 'my_session_key'
    item_key 'A1'
    active 1
  end
end
