class DataValue < ActiveRecord::Base
  self.table_name = 'data_values'
  database_config = Rails.configuration.database_configuration[Rails.env]["gsdata"]
  self.establish_connection(database_config)

  DATA_CONFIGURATION = 'web'

  def self.find_by_school_and_data_types(school, data_types, breakdown_tag_names = [])
    school_values.
      from(
        DataValue.school_and_data_types(school.state,
                                       school.id,
                                       data_types), :data_values)
          .with_data_types
          .with_sources
          .with_breakdowns
          .with_breakdown_tags(breakdown_tag_names)
          .group('data_values.id')
          .having("breakdown_count < 2 OR breakdowns like '%All students except 504 category%'")
  end

  def self.school_values
    school_values = <<-SQL
      data_values.id, data_values.value, data_values.state, data_values.school_id,
      data_values.data_type_id, data_values.configuration, data_types.name,
      sources.source_name, sources.date_valid,
      group_concat(distinct breakdowns.name ORDER BY breakdowns.name) as "breakdowns",
      group_concat(distinct bt.tag ORDER BY bt.tag) as "breakdown_tags",
      count(distinct(breakdowns.name)) as "breakdown_count"
    SQL
    select(school_values)
  end

  def self.find_by_state_and_data_types(state, data_types, breakdown_tag_names = [])
    state_and_district_values.
      from(
        DataValue.state_and_data_types(
          state,
          data_types
        ), :data_values)
          .with_breakdowns
          .with_breakdown_tags(breakdown_tag_names)
          .with_sources
          .group('data_values.id')
  end

  def self.find_by_district_and_data_types(state, district_id, data_types, breakdown_tag_names = [])
    state_and_district_values.
      from(
        DataValue.state_and_district_data_types(
          state,
          district_id,
          data_types
        ), :data_values)
          .with_breakdowns
          .with_breakdown_tags(breakdown_tag_names)
          .with_sources
          .group('data_values.id')
  end

  def self.state_and_district_values
    state_and_district_values = <<-SQL
      data_values.id, data_type_id, data_values.value, date_valid,
      group_concat(breakdowns.name ORDER BY breakdowns.name) as "breakdowns"
    SQL
    select(state_and_district_values)
  end

  def self.school_and_data_types(state, school_id, data_type_ids)
    school_subquery_sql = <<-SQL
          state = ?
          AND district_id IS NULL
          AND school_id = ?
          AND data_type_id IN (?)
          AND active = 1
    SQL
    data_types = Array.wrap(data_type_ids)
    where(school_subquery_sql, state, school_id, data_types)
  end

  def self.state_and_data_types(state, data_type_ids)
    data_types = Array.wrap(data_type_ids)
    state_subquery_sql = <<-SQL
      state = ?
      AND district_id IS NULL
      AND school_id IS NULL
      AND data_type_id IN (?)
      AND active = 1
    SQL
    where(state_subquery_sql, state, data_types)
  end

  def self.state_and_district_data_types(state, district_id, data_type_ids)
    district_subquery = <<-SQL
      state = ?
      AND district_id = ?
      AND school_id IS NULL
      AND data_type_id IN (?)
      AND active = 1
    SQL
    data_types = Array.wrap(data_type_ids)
    where(district_subquery, state, district_id,  data_types)
  end

  def self.with_data_types
    joins("JOIN data_types on data_type_id = data_types.id")
  end

  def self.with_sources
    joins("JOIN sources on sources.id = source_id")
  end

  def self.with_breakdowns
    joins(<<-SQL
      LEFT JOIN data_values_to_breakdowns
        ON data_values.id = data_values_to_breakdowns.data_value_id
      LEFT JOIN breakdowns
        ON breakdowns.id = data_values_to_breakdowns.breakdown_id
      SQL
      )
  end

  def self.with_breakdown_tags(breakdown_tag_names = [])
    if breakdown_tag_names.present?
      q = <<-SQL
        LEFT JOIN (select breakdown_id,tag from breakdown_tags where tag in ('#{breakdown_tag_names.join('\',\'')}')) bt
        ON bt.breakdown_id = breakdowns.id
      SQL
    else
      q = <<-SQL
        LEFT JOIN breakdown_tags bt
        ON bt.breakdown_id = breakdowns.id
      SQL
    end
    ar = joins(q)
    ar
  end

  def datatype_breakdown_year
    [data_type_id, breakdowns, date_valid]
  end
end
