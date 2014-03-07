FactoryGirl.define do
  factory :category do
    sequence :id do |n|
      n
    end

    name 'Test category'
  end
end