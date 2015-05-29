FactoryGirl.define do

  factory :role, class: Role do
    id 1
    quay 'ESP_SUPERUSER'
    description 'has access to all schools in the country'
  end

end
