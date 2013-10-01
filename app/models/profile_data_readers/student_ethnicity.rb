class StudentEthnicity

  def key
    'ethnicity_data'
  end

  def initialize(category)
    @category = category
  end

  def query(school)
    ethnicity_data_types = [9]

    #json_data = SchoolCategoryData

    school.census_data_for_data_types ethnicity_data_types
    # Run some query and get back a resultset
  end

  def data(school)
    rows = query(school).inject([]) do |rows_array, census_data|
      school_values = school.census_data_school_values.having_data_set(census_data)
      school_value = nil
      if Array(school_values).any?
        first = school_values[0]
        school_value = school_values[0].value_float unless first.nil?
      end

      state_values = census_data.census_data_state_values
      state_value = nil
      if (Array(state_values)).any?
        first = state_values[0]
        state_value = state_values[0].value_float unless first.nil?
      end

      description = ''
      if census_data.census_breakdown
        description = census_data.census_breakdown
      end

      if state_value && school_value
        rows_array << {
            ethnicity: description,
            school_value: school_value.round,
            state_value: state_value.round
        }
      end

      rows_array
    end

    rows.sort_by! {|row| row[:school_value] }.reverse!

    # handle checking request-scoped cached results, maybe get a higher-level resultset and filter out unneeded data
    # maybe actually run the query() method
    # return results
    rows
  end

  def table_data(school)
    rows = data(school)

    if rows.any?
      TableData.new rows
    end
  end

  def prettify_data(school, table_data)
    table_data
  end

end