FactoryGirl.define do
  factory :school_data_value, class: OpenStruct do
    sequence :id do |n|
      n
    end
    value 1
    name 'Sample data type'
    breakdowns 'Male'
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
