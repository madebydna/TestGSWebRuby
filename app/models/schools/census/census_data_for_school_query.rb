class CensusDataForSchoolQuery

  def initialize(school, relation = nil)
    @relation = relation || CensusDataSet.on_db(school.shard)
    @school = school
    @state = school.state
  end

  def base_data_type_ids
    [9, 17, 41, 5, 110]
  end

  def data_for_school(data_type_names = [])
    data_type_names = Array(data_type_names)

    data_type_ids = base_data_type_ids + CensusDataType.reverse_lookup(data_type_names).map(&:id)
    data_type_ids.uniq!

    results = CensusDataSet.census_data_for_school_and_data_type_ids(@school, data_type_ids)

    # Only use data where there's a matching row in census_data_config_entry
    # census_data_sets.select!(&:has_config_entry?)

    CensusDataResults.new(results)
  end

  def latest_data_for_school(*args)
    results = data_for_school *args
    results.filter_to_max_year_per_data_type!
    results
  end

end