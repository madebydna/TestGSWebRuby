FactoryGirl.define do
  trait :active do
    active 1
  end
  trait :inactive do
    active 0
  end
end