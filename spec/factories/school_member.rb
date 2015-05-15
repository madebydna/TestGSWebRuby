FactoryGirl.define do

  factory :school_member, class: SchoolMember do
    sequence(:id) { |n| n }

    factory :parent_school_member do
      user_type 'parent'
    end
    factory :student_school_member do
      user_type 'student'
    end
    factory :teacher_school_member do
      user_type 'teacher'
    end
    factory :principal_school_member do
      user_type 'principal'
    end
    factory :community_school_member do
      user_type 'community member'
    end
  end

end