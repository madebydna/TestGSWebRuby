FactoryGirl.define do
  factory :user do
    sequence :id do |n|
      n
    end

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
