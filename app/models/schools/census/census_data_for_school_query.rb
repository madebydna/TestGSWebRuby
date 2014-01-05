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

    max_years = CensusDataSet.max_year_per_data_type(@state)

    years = max_years.select { |data_type_id| data_type_ids.include? data_type_id }.values

    years << 0

    results =
      @relation.on_db(@school.shard)
      .active
      .with_data_types(data_type_ids)
      .where(year: years)
      .include_school_district_state(@school.id, @school.district_id)

    CensusDataResults.new(results.all)
  end

  def latest_data_for_school(*args)
    results = data_for_school *args
    results.filter_to_max_year_per_data_type! @state
    results
  end

end