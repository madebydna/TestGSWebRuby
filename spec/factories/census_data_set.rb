FactoryGirl.define do

  factory :census_data_school_value, class: CensusDataSchoolValue do
    sequence(:value_float)
  end

  factory :census_data_district_value, class: CensusDataSchoolValue do
    sequence(:value_float)
  end

  factory :census_data_state_value, class: CensusDataSchoolValue do
    sequence(:value_float)
  end

  factory :census_data_set, class: CensusDataSet do
    data_type_id 1
    year 2011
    active 1
    level_code 'e,m,h'
    grade '9'

    factory :ethnicity_data_set, class: CensusDataSet do
      data_type_id 9
    end
    factory :enrollment_data_set, class: CensusDataSet do
      data_type_id 17
    end

  end

end