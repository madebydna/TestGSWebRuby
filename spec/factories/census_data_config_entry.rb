FactoryGirl.define do

  factory :census_data_config_entry, class: CensusDataConfigEntry do
    sequence(:id)
    group_id 1
    data_type_id 1
    breakdown_id nil
    data_type_label 'a data type label'
    label 'a label'
    school_type 'public'
    level_code nil
    use_school_data 1
    use_district_data 1
    use_state_data 1
    grade 'All'
    sort 1

    factory :census_data_config_entry_null_breakdown do
      breakdown_id nil
    end

    factory :census_data_config_entry_with_breakdown do
      breakdown_id 1
    end
  end

end
