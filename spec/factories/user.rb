FactoryGirl.define do
  factory :user do
    sequence(:id) { |n| n }
    sequence(:email) { |n| "test+#{n}@greatschools.org" }
    password 'password'

    factory :email_only do
    end

    factory :new_user do
      password 'password'
    end

    factory :verified_user do
      password 'password'
      email_verified true
      first_name 'Holographic'
      last_name 'Universe'
    end

    trait :with_approved_esp_membership do
      ignore do
        school_id 1 #default
        state 'ca' #default
      end

      after(:create) do |user, evaluator|
        FactoryGirl.create(:esp_membership, :with_approved_status,school_id: evaluator.school_id,state:evaluator.state,member_id: user.id)
      end
    end

    trait :with_provisional_esp_membership do
      ignore do
        school_id 1 #default
        state 'ca' #default
      end

      after(:create) do |user, evaluator|
        FactoryGirl.create(:esp_membership, :with_provisional_status ,school_id: evaluator.school_id,state:evaluator.state,member_id: user.id)
      end
    end

    trait :with_approved_superuser_membership do
      ignore do
        school_id nil #default
        state nil #default
      end

      after(:create) do |user, evaluator|
        FactoryGirl.create(:esp_membership, :with_approved_status, school_id: evaluator.school_id, state: evaluator.state, member_id: user.id)
        FactoryGirl.create(:role, id: 8)
        FactoryGirl.create(:member_role, role_id: 8, member_id: user.id)
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

    #usage let!(:user) {FactoryGirl.create(:verified_user,:with_role,:role_id=>8 )}
    trait :with_subscriptions do
      ignore do
        list 'greatnews'
        number_of_subscriptions 1
      end

      after(:create) do |user, evaluator|
        FactoryGirl.create_list(:subscription,evaluator.number_of_subscriptions, list: evaluator.list,member_id:user.id)
      end
    end

    trait :with_school_subscriptions do
      ignore do
        lists ['mystat']
        lists_schools [FactoryGirl.build(:school)]
        number_of_subscriptions 1
      end

      after(:create) do |user, evaluator|
        evaluator.lists.each_with_index do |list, i|
          school = evaluator.lists_schools[i]
          FactoryGirl.create(:subscription,
                             list: list,
                             member_id:user.id,
                             school_id: school.id,
                             state: school.state,
                            )
        end
      end
    end

  end

end
