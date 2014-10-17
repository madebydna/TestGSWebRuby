FactoryGirl.define do

  factory :esp_superuser_role, class: Role do
    quay 'ESP_SUPERUSER'
    description 'has access to all schools in the country'
  end

end