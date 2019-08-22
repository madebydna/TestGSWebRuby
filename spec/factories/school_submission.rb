# frozen_string_literal: true

FactoryBot.define do

  factory :new_school_submission, class: NewSchoolSubmission do
    sequence :id do |n|
      n
    end
    state 'wy'
    state_school_id '123456789'
    school_name 'Magnatar'
    district_name 'Pulsar'
    county 'Virgo Supercluster'
    physical_address 'Sombrero Galaxy'
    physical_city 'Via Lactea'
    physical_zip_code 12345
    mailing_address 'Sombrero Galaxy'
    mailing_city 'Via Lactea'
    mailing_zip_code 12345
    grades 'kg,6,11'
  end

  trait :public_school do
    nces_code 123456789876
    school_type 'public'
  end

  trait :private_school do
    nces_code 12345678
    school_type 'private'
  end

  factory :remove_school_submission, class: RemoveSchoolSubmission do
    submitter_email 'alex-anthony-derek-mitch-samson@gs-the-bes.com'
    submitter_role 'coffee taster'
    evidence_url 'www.really_good_gesha_coffee.com'
    gs_url 'https://www.greatschools.org/california/alameda/1-Alameda-High-School'
  end

end
