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

    census_data_sets =
      @relation.on_db(@school.shard)
      .active
      .with_data_types(data_type_ids)
      .include_school_district_state(@school.id, @school.district_id)

    # If there is no district for a school and hence no district values, prevent the district from being
    # lookup up via association chaining on these resulting census_data_sets
    # If caller asks for census_data_set.district_value, they'll just get nil
    census_data_sets.each { |r| r.association(:census_data_district_values).target = [] } if @school.district_id < 1

    CensusDataResults.new(census_data_sets.all)
  end

  def latest_data_for_school(*args)
    results = data_for_school *args
    results.filter_to_max_year_per_data_type!
    results
  end

end