FactoryGirl.define do
  factory :user do
    sequence(:id) { |n| n }
    sequence(:email) { |n| "test+#{n}@greatschools.org" }
    password 'password'

    factory :email_only do
      email 'test@greatschools.org'
    end

    factory :new_user do
      email 'test@greatschools.org'
      password 'password'
    end

    factory :verified_user do
      email 'test@greatschools.org'
      password 'password'
      email_verified true
    end

  end

end
