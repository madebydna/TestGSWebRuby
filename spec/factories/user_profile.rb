FactoryGirl.define do
  factory :user_profile do
    sequence(:id) { |n| n }
    active 1
    created Time.now

    factory :disabled_user_profile do
      active 0
      factory :inactive_user_profile
    end
  end



end