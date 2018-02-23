# frozen_string_literal: true

FactoryGirl.define do
  sequence :id do |n|
    n
  end

  factory :new_school_submission do
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
    level 'e,h,m'
  end

  trait :public_school do
    nces_code 123456789876
    school_type 'public'
  end

  trait :private_school do
    nces_code 12345678
    school_type 'private'
  end

end