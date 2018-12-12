FactoryGirl.define do
  factory :new_school_submission_prek, class: NewSchoolSubmission do
    school_name 'Landels Preschool'
    nces_code nil 
    school_id nil 
    state 'CA'
    state_school_id nil 
    district_name 'Mountain View Whisman School District'
    county 'Santa Clara'
    physical_address '1122 Castro Street'
    physical_city 'Mountain View'
    physical_zip_code '94040'
    mailing_address '1122 Castro Street'
    mailing_city 'Mountain View'
    mailing_zip_code '94040'
    grades 'pk'
    phone_number '650-123-4567'
    level 'p'
    school_type 'public'
    url 'https://www.landelspreschool.com'
  end
end