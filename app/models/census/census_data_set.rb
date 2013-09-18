class CensusDataSet < ActiveRecord::Base
  self.table_name = 'census_data_set'
  self.inheritance_column = nil

  has_many :census_data_school_values, class_name: 'CensusDataSchoolValue', foreign_key: 'data_set_id'
  has_many :census_data_district_values, class_name: 'CensusDataDistrictValue', foreign_key: 'data_set_id'
  has_many :census_data_state_values, class_name: 'CensusDataStateValue', foreign_key: 'data_set_id'
  has_one :census_breakdown, foreign_key: 'datatype_id'

  scope :with_data_types, lambda { |data_type_ids|
    where(data_type_id: Array(data_type_ids))
  }

  scope :include_school_district_state, lambda {


    # eager load is slower when more census_data_sets match more school values
    # generally three separate queries seems faster
    preload(:census_data_school_values)
    .preload(:census_data_state_values)
  }

  scope :active, where(active: true)

  def self.max_year_per_data_type(state)
    @state_max_years ||= {}

    #Rails.cache.fetch("census_data_set/max_year_per_data_type/#{state}", expires_in: 5.minutes) do
    @state_max_years[state] ||= using(state.upcase.to_sym).having_school_values.group(:data_type_id).maximum(:year)
    #end

    @state_max_years[state]
  end

  scope :having_school_values, joins(:census_data_school_values)

  def self.by_data_types(state, data_type_ids = [])
    #max_years = max_year_per_data_type(state)
    #max_years.select! { |data_type_id| data_type_ids.include? data_type_id }

    results = using(state.upcase.to_sym)
      .with_data_types(data_type_ids)
      .active
      .where(year: 2011)
      .all

    #results.select { |result| result.year == 0 || max_year_per_data_type(state)[result.data_type_id] == result.year }
  end

  def census_breakdown
    # TODO: fix hardcoded value
    #CensusBreakdown.using(:master).where(datatype_id: '11', id: lookup[breakdown_id]).first
    breakdown = lookup[breakdown_id]
    lookup_breakdown_text[breakdown]
  end

  def lookup_breakdown_text
    {
      1 => 'White, non-Hispanic',
      2 => 'Black, non-Hispanic',
      3 => 'Hispanic',
      4 => 'American Indian/Alaskan Native',
      5 => 'Asian/Pacific Islander',
      6 => 'Multiracial',
      7 => 'Asian',
      8 => 'Pacific Islander',
      10 => 'Native American or Native Alaskan',
      11 => 'Hawaiian',
      12 => 'Unspecified',
      13 => 'Filipino',
      14 => 'Native Hawaiian or Other Pacific Islander'
    }
  end

  def lookup
    {
      1 => 1,
      2 => 2,
      3 => 3,
      4 => 4,
      5 => 5,
      6 => 6,
      7 => 7,
      8 => 8,
      9 => 9,
      10 => 10,
      11 => 11,
      12 => 12,
      162 => 13,
      209 => 14,
      201 => 18,
      202 => 15,
      203 => 16,
      204 => 17,
      207 => 19,
      208 => 20
    }
  end

end
