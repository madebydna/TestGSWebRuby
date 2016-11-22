class DataValue < ActiveRecord::Base
  self.table_name = 'data_value'
  database_config = Rails.configuration.database_configuration[Rails.env]["gsdata"]
  self.establish_connection(database_config)

  DATA_CONFIGURATION = 'none'

  def self.value_for_state_by_breakdown(state, data_type)
    state_cache_values.
      from(
        DataValue.state_and_data_type(
          state,
          data_type
        ), :data_value)
          .with_breakdowns
          .with_sources
          .group('data_value.id')
  end

  def self.value_for_district_by_breakdown(state, district_id, data_type)
    state_cache_values.
      from(
        DataValue.state_and_district_data_type(
          state,
          district_id,
          data_type
        ), :data_value)
          .with_breakdowns
          .with_sources
          .group('data_value.id')
  end

  def self.value_for_school_and_data_type_by_breakdown(school, data_type)
    school_cache_values.
      from(
        DataValue.school_and_data_type(school.state,
                                       school.id,
                                       data_type), :data_value)
          .with_data_types
          .with_sources
          .with_breakdowns
          .group('data_value.id')
  end

  def self.school_cache_values
    school_values = <<-SQL
      data_value.id, data_value.value, data_value.state, data_value.school_id,
      data_value.data_type_id, data_value.configuration, data_type.name,
      source.source_name, source.date_valid,
      group_concat(breakdown.name ORDER BY breakdown.name) as "breakdowns"
    SQL
    select(school_values)
  end

  def self.district_cache_values
    district_values = <<-SQL
      data_value.id, data_type_id, data_value.value, date_valid, 
      group_concat(breakdown.name ORDER BY breakdown.name) as "breakdowns"
    SQL
    select(district_values)
  end

  def self.state_cache_values
    state_values = <<-SQL
      data_value.id, data_type_id, data_value.value, date_valid, 
      group_concat(breakdown.name ORDER BY breakdown.name) as "breakdowns"
    SQL
    select(state_values)
  end

  def self.school_and_data_type(state, school_id, data_type_id)
    school_subquery_sql = <<-SQL
          state = ?
          AND district_id IS NULL 
          AND school_id = ?
          AND data_type_id IN (?)
          AND active = 1
          AND configuration = '#{DATA_CONFIGURATION}'
    SQL
    data_types = Array.wrap(data_type_id)
    where(school_subquery_sql, state, school_id, data_types)
  end

  def self.state_and_data_type(state, data_type_id)
    data_types = Array.wrap(data_type_id)
    state_subquery_sql = <<-SQL
      state = ?
      AND district_id IS NULL
      AND school_id IS NULL
      AND data_type_id IN (?)
      AND active = 1
      AND configuration = '#{DATA_CONFIGURATION}'
    SQL
    where(state_subquery_sql, state, data_types)
  end

  def self.state_and_district_data_type(state, district_id, data_type_id)
    district_subquery = <<-SQL
      state = ?
      AND district_id = ?
      AND school_id IS NULL
      AND data_type_id IN (?)
      AND active = 1
      AND configuration = '#{DATA_CONFIGURATION}'
    SQL
    data_types = Array.wrap(data_type_id)
    where(district_subquery, state, district_id,  data_types)
  end

  def self.with_data_types
    joins(" JOIN data_type on data_type_id = data_type.id")
  end

  def self.with_sources
    joins("JOIN source on source.id = source_id")
  end

  def self.with_breakdowns
    joins(<<-SQL
      LEFT JOIN data_to_breakdown on data_value.id = data_to_breakdown.data_value_id
      LEFT JOIN breakdown on breakdown.id = data_to_breakdown.breakdown_id
      SQL
      )
  end

  def datatype_breakdown_year
    [data_type_id, breakdowns, date_valid]
  end

end
