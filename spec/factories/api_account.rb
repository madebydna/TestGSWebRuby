FactoryGirl.define do

  factory :api_account, class: ApiAccount do
    name 'Curious George'
    organization 'Yellow Hat, Inc.'
    email 'curious@george.com'
    website 'curious-george.com'
    phone '123-456-7899'
    industry 'Education'
    intended_use 'Testing'
    type 'Test account'
    account_added :account_added
  end

end

