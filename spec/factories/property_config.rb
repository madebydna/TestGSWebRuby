FactoryGirl.define do
  factory :property_config do
    sequence :id do |n|
      n
    end

    quay 'rubySearchStates'
    value 'de,in,mi,wi'
  end
end
