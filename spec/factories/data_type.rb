FactoryGirl.define do
  factory :data_type, class: DataType do
    sequence :id do |n|
      n
    end
    name 'foo'
  end
end
