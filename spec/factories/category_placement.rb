FactoryGirl.define do
  factory :category_placement do
    sequence :id do |n|
      n
    end

    sequence :position do |n|
      n
    end

    page name: 'Test page'
  end
end