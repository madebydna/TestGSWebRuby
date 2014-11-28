class CensusLoading::Base < Loader

  @@census_data_types = Hash[CensusDataType.all.map { |f| [f.description, f] }]
  @@census_data_breakdowns = Hash[CensusDataBreakdown.all.map { |f| [f.id, f] }]
  @@census_data_ethnicities = Hash[Ethnicity.all.map { |f| [f.name, f] }]
  @@census_data_subjects = Hash[TestDataSubject.all.map { |f| [f.name, f] }]

  cattr_accessor :census_data_types, :census_data_breakdowns, :census_data_subjects, :census_data_ethnicities

  def census_data_types
    @@census_data_types
  end

  def census_data_breakdowns
    @@census_data_breakdowns
  end

  def census_data_subjects
    @@census_data_subjects
  end

  def census_data_ethnicities
    @@census_data_ethnicities
  end

  def census_data_type_from_name(data_type_name)
    data_type_arr = census_data_types.find { |dt| dt[0].casecmp(data_type_name) == 0 }
    data_type_arr ? data_type_arr[1] : nil
  end

end