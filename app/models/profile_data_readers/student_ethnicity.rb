class StudentEthnicity

  def key
    'ethnicity_data'
  end

  def initialize(category)
    @category = category
  end

  def data(school)
    rows = CensusData.census_data_for_school(school).map do |census_data|
      if census_data[:state_value] && census_data[:school_value]
        {
            ethnicity: census_data[:breakdown],
            school_value: census_data[:school_value].round,
            state_value: census_data[:state_value].round
        }
      end
    end.compact

    rows.sort_by { |row| row[:school_value] }.reverse
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