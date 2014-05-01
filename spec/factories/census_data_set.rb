require 'rspec/mocks/standalone'

FactoryGirl.define do

  sequence :school_value_float do |n|
    n
  end

  factory :census_data_school_value, class: CensusDataSchoolValue do
    value_float { generate(:school_value_float) }
    sequence(:school_id)
    active 1
  end

  factory :census_data_district_value, class: CensusDataDistrictValue do
    sequence(:value_float)
    sequence(:district_id)
    active 1
  end

  factory :census_data_state_value, class: CensusDataStateValue do
    sequence(:value_float)
    active 1
  end

  factory :ethnicity_data_set_results, class: CensusDataResults do
    ignore do
      number_of_data_sets 3
    end
    after(:stub) do |array, evaluator|
      array.replace FactoryGirl.build_stubbed_list(
        :census_data_set,
        evaluator.number_of_data_sets,
        :various_breakdowns,
        :with_school_values,
        data_type_id: 9
      )
    end
    initialize_with do |evaluator|
      obj = new([])
      obj.stub(:id) {}
      obj.stub(:id=) {}
      obj
    end
  end

  factory :census_data_set, class: CensusDataSet do
    data_type_id 1
    year 2011
    active 1
    level_code 'e,m,h'
    grade '9'

    ignore do
      school_value_modified '2000-01-01'
      school_value_float { generate(:school_value_float) }
      # We need to set school values even if they will be an empty array
      # So as to prevent a db lookup if school_values method accessed
      # on data set
      number_of_school_values 0
      number_of_district_values 0
      number_of_state_values 0
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

    trait :various_breakdowns do
      sequence(:breakdown_id)
    end

    after :build do |data_set, evaluator|
      data_set.census_data_school_values =
        FactoryGirl.build_list(
          :census_data_school_value,
          evaluator.number_of_school_values,
          modified: evaluator.school_value_modified,
          value_float: evaluator.school_value_float
        )

      data_set.census_data_district_values =
        FactoryGirl.build_list(
          :census_data_district_value,
          evaluator.number_of_district_values
        )

      data_set.census_data_state_values =
        FactoryGirl.build_list(
          :census_data_state_value,
          evaluator.number_of_state_values
        )
    end

    after :create do |data_set, evaluator|
      data_set.stub(:census_data_school_values) do
        FactoryGirl.create_list(
          :census_data_school_value,
          evaluator.number_of_school_values,
          modified: evaluator.school_value_modified,
          value_float: evaluator.school_value_float
        )
      end

      data_set.stub(:census_data_district_values) do
        FactoryGirl.create_list(
          :census_data_district_value,
          evaluator.number_of_district_values
        )
      end

      data_set.stub(:census_data_state_values) do
        FactoryGirl.create_list(
          :census_data_state_value,
          evaluator.number_of_state_values
        )
      end
    end

    after :stub do |data_set, evaluator|
      data_set.stub(:census_data_school_values) do
        FactoryGirl.build_stubbed_list(
          :census_data_school_value,
          evaluator.number_of_school_values,
          modified: evaluator.school_value_modified,
          value_float: evaluator.school_value_float
        )
      end

      data_set.stub(:census_data_district_values) do
        FactoryGirl.build_stubbed_list(
          :census_data_district_value,
          evaluator.number_of_district_values
        )
      end

      data_set.stub(:census_data_state_values) do
        FactoryGirl.build_stubbed_list(
          :census_data_state_value,
          evaluator.number_of_state_values
        )
      end
    end

    trait :with_school_value do
      number_of_school_values 1
    end

    trait :with_school_values do
      number_of_school_values 2
    end

    trait :with_district_value do
      number_of_district_values 1
    end

    trait :with_district_values do
      number_of_district_values 2
    end

    trait :with_state_value do
      number_of_state_values 1
    end
  end
end
