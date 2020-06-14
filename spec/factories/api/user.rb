FactoryBot.define do
  factory :api_user, class: Api::User do
    first_name 'Curious'
    last_name 'George'
    organization 'Curious George'
    website 'Curious George'
    email 'Curious George'
    phone 'Curious George'
    city 'Curious George'
    state 'Curious George'
    organization_description 'Curious George'
    role 'Curious George'
    intended_use 'Curious George'
  end
end

