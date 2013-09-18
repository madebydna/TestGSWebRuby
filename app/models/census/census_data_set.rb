class CensusDataSet < ActiveRecord::Base
  self.table_name = 'census_data_set'
  self.inheritance_column = nil

  has_many :census_data_school_values, class_name: 'CensusDataSchoolValue', foreign_key: 'data_set_id'
  has_many :census_data_district_values, class_name: 'CensusDataDistrictValue', foreign_key: 'data_set_id'
  has_one :census_data_state_values, class_name: 'CensusDataStateValue', foreign_key: 'data_set_id'

  scope :with_data_types, lambda { |data_type_ids|
    where(data_type_id: Array(data_type_ids))
  }

  scope :include_school_district_state, lambda {


    # eager load is slower when more census_data_sets match more school values
    # generally three separate queries seems faster
=begin
    eager_load(:census_data_school_values)
    .eager_load(:census_data_district_values)
    .eager_load(:census_data_state_values)
=end
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
    results = using(state.upcase.to_sym)
      .with_data_types(data_type_ids)
      .active
      .include_school_district_state
      .where(year: max_year_per_data_type(state).values)
      .all

    results.select { |result| result.year == 0 || max_year_per_data_type(state)[result.data_type_id] == result.year }
  end

end
