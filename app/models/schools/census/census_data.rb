class CensusData

  def self.data_for_school(school)
    ethnicity_data_types = [9, 17]

    results = CensusDataSet.on_db(school.shard)
      .by_data_types(school.state, ethnicity_data_types)
      .include_school_district_state(school.id)
      .all

    rows = results.map(&:to_hash)

    rows_per_data_type = rows.group_by(&:data_type)
  end

end