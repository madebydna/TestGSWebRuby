FactoryGirl.define do

  factory :role, class: Role do
    # role_id :role_id
    quay 'ESP_SUPERUSER'
    description 'has access to all schools in the country'
  end

end