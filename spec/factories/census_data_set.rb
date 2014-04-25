FactoryGirl.define do

  factory :census_data_school_value, class: CensusDataSchoolValue do
    sequence(:value_float)
  end

  factory :census_data_district_value, class: CensusDataDistrictValue do
    sequence(:value_float)
  end

  factory :census_data_state_value, class: CensusDataStateValue do
    sequence(:value_float)
  end

  factory :census_data_set, class: CensusDataSet do
    data_type_id 1
    year 2011
    active 1
    level_code 'e,m,h'
    grade '9'

    after(:stub) do |data_set, evaluator|
      data_set.stub(:census_data_school_values).and_return(
        FactoryGirl.build_stubbed_list(
          :census_data_school_value, 2
        )
      )
      data_set.stub(:census_data_district_values).and_return(
        FactoryGirl.build_stubbed_list(
          :census_data_district_value, 1
        )
      )
      data_set.stub(:census_data_state_values).and_return(
        FactoryGirl.build_stubbed_list(
          :census_data_state_value, 1
        )
      )
    end

    factory :ethnicity_data_set, class: CensusDataSet do
      data_type_id 9
    end

    factory :enrollment_data_set, class: CensusDataSet do
      data_type_id 17
    end

    factory :manual_override_data_set, class: CensusDataSet do
      year 0
    end
  end

end