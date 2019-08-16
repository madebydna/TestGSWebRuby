FactoryBot.define do
  factory :data_value, class: DataValue do
    sequence :id do |n|
      n
    end
    value nil
    state 'CA'
    school_id nil
    district_id nil
    data_type_id nil
    source_id 1
    configuration 'web'
    active 1
    created Time.now
    updated Time.now
  end

  factory :school_data_value, class: OpenStruct do
    sequence :id do |n|
      n
    end
    value 1
    name 'Sample data type'
    breakdowns 'Male'
    breakdown_tags 'Gender'
    source_name 'Sample Source'
    date_valid Time.parse("Jan 1 2014")
    state 'CA'
    school_id 1
    district_id 1
    data_type_id 1
    source_id 1
    configuration 'web'
    active 1
  end
end
