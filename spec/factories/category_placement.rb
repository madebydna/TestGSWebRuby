FactoryGirl.define do
  factory :category_placement do
    sequence :id do |n|
      n
    end

    sequence :position do |n|
      n
    end

    category
    page
  end
end