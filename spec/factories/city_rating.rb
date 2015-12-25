FactoryGirl.define do
  factory :city_rating do
    sequence(:id) { |n| n }
    city :alameda
    rating 10
    active true
  end
end