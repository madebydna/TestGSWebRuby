FactoryGirl.define do

  factory :school_user, class: SchoolUser do
    sequence(:id) { |n| n }

    factory :parent_school_user do
      user_type 'parent'
    end
    factory :student_school_user do
      user_type 'student'
    end
    factory :teacher_school_user do
      user_type 'teacher'
    end
    factory :principal_school_user do
      user_type 'principal'
    end
    factory :community_school_user do
      user_type 'community member'
    end
  end

end