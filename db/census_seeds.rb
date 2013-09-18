=begin
cds_data_type_nine = CensusDataSet.create!(data_type_id: 9, breakdown: nil, grade: nil, year: 2013, level_code: 'p,e,m,h', active: true)

CensusDataSchoolValue.using(:CA).create!(
    school: alameda_high_school,
    census_data_set: cds_data_type_nine,
    value_float: 9.9,
    value_text: nil,
    active: true
)

CensusDataSchoolValue.using(:CA).create!(
    school: lincoln,
    census_data_set: cds_data_type_nine,
    value_float: 29.9,
    value_text: nil,
    active: true
)

CensusDataSchoolValue.using(:CA).create!(
    school: lowell_middle_school,
    census_data_set: cds_data_type_nine,
    value_float: 29.9,
    value_text: nil,
    active: true
)=end
