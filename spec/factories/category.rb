FactoryGirl.define do
  factory :category do
    sequence :id do |n|
      n
    end

    name 'Test category'
    category_datas { FactoryGirl.build_list(:category_data, 1, response_key: 'a_key', label: 'a label' ) }
  end
end