
SchoolCategoryData.using(@alameda_high_school.state.upcase.to_sym).create!(key: 'student_ethnicity',school: @alameda_high_school,school_data: {
  rows: [
    {
        ethnicity: 'Asian',
        school_value: '51',
        state_value: '11'
    },
    {
        ethnicity: 'White',
        school_value: '32',
        state_value: '27'
    },
    {
        ethnicity: 'Hispanic',
        school_value: '9',
        state_value: '51'
    },
    {
        ethnicity: 'Black',
        school_value: '6',
        state_value: '7'
    },
    {
        ethnicity: 'Hawaiian Native/Pacific Islander',
        school_value: '1',
        state_value: '1'
    },
    {
        ethnicity: 'Two or more races',
        school_value: '1',
        state_value: '3'
    },
    {
        ethnicity: 'American Indian/Alaska Native',
        school_value: '0',
        state_value: '1'
    },
  ]
}.to_json )
