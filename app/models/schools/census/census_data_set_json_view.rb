class CensusDataSetJsonView
  attr_reader :data_set

  def initialize(data_set)
    @data_set = data_set
  end

  def to_hash
    if data_set.state_value || data_set.school_value
      {
        breakdown: data_set.config_entry_breakdown_label ||
                   data_set.census_breakdown,
        school_value: data_set.school_value,
        district_value: data_set.district_value,
        state_value: data_set.state_value,
        source: data_set.source,
        year: data_set.year == 0 ?
          data_set.school_modified.year : data_set.year
      }
    end
  end
end
