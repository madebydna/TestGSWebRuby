FactoryBot.define do
  factory :api_user, class: Api::User do
    first_name 'Curious'
    last_name 'George'
    organization 'Curious George inc'
    website 'www.curiousgeorge.com'
    email 'curious@george.com'
    phone '3 21 18 9 15 21 19 7 5 15 18 7 5'
    city 'Curious George land'
    state 'Georgea'
    intended_use 'Curiousity'
    intended_use_details 'Curiously explore'
    organization_description '123 Curious George street'
    role 'Chief Curiosity office'

  end
end

