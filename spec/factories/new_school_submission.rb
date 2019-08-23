FactoryBot.define do
  factory :new_school_submission_k12, class: NewSchoolSubmission do
    school_name 'Landels Academy'
    nces_code '112358132134'
    school_id 7491275
    state 'ca'
    state_school_id '123454321' 
    district_name 'Mountain View Whisman School District'
    county 'Santa Clara'
    physical_address '2211 Castro Street'
    physical_city 'Mountain View'
    physical_zip_code 94040
    mailing_address '2211 Castro Street'
    mailing_city 'Mountain View'
    mailing_zip_code 94040
    grades '6,7,8'
    phone_number '650-123-4567'
    level 'm'
    school_type 'public'
    url 'https://www.landelspreschool.com'
  end

  factory :new_school_submission_prek, class: NewSchoolSubmission do
    school_name 'Landels Preschool'
    nces_code nil 
    school_id nil 
    state 'ca'
    state_school_id nil 
    district_name 'Mountain View Whisman School District'
    county 'Santa Clara'
    physical_address '1122 Castro Street'
    physical_city 'Mountain View'
    physical_zip_code 94040
    mailing_address '1122 Castro Street'
    mailing_city 'Mountain View'
    mailing_zip_code 94040
    grades 'pk'
    phone_number '650-123-4567'
    level 'p'
    school_type 'public'
    url 'https://www.landelspreschool.com'
  end
end
