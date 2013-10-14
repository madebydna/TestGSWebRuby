class CensusDataForSchoolQuery

  def initialize(school, relation = nil)
    @relation = relation || CensusDataSet.on_db(school.shard)
    @school = school
    @state = school.state
  end

  def default_data_type_ids
    [9, 17]
  end

  def data_for_school(data_type_ids = default_data_type_ids)

    max_years = CensusDataSet.max_year_per_data_type(@state)

    years = max_years.select { |data_type_id| data_type_ids.include? data_type_id }.values

    years << 0

    results =
      @relation.active
      .with_data_types(data_type_ids)
      .where(year: years)
      .include_school_district_state(@school.id)
      .all

    CensusDataResults.new(results)
  end

end