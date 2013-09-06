class StudentEthnicity

  def data_category
    # return the name of the category of data. i.e. "StudentEthnicity". Class name by default?
  end

  def query
    # Run some query and get back a resultset
  end

  def get_data(school)
    # handle checking request-scoped cached results, maybe get a higher-level resultset and filter out unneeded data
    # maybe actually run the query() method
    # return results

    to_json(nil)
  end

  def to_json(data)
    results = []

    # for each resultset
    # push a new hash onto the array:

    results =
        [
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
  end

end