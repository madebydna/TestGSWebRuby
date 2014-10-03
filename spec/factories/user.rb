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

    trait :with_approved_esp_membership do
      ignore do
        school_id 1 #default
        state 'ca' #default
      end

      after(:create) do |user, evaluator|
        FactoryGirl.create(:approved_esp_membership,school_id: evaluator.school_id,state:evaluator.state,member_id: user.id)
      end
    end

    #usage let!(:user) {FactoryGirl.create(:verified_user,:with_role,:role_id=>8 )}
    trait :with_role do
      ignore do
        role_id 9 #default
      end

      after(:create) do |user, evaluator|
        FactoryGirl.create(:member_role,member_id: user.id,role_id:evaluator.role_id)
      end
    end

  end

end
