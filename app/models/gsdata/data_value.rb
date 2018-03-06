# frozen_string_literal: true

class DataValue < ActiveRecord::Base
  self.table_name = 'data_values'

  db_magic connection: :gsdata

  attr_accessible :value, :state, :school_id, :district_id, :data_type_id,
    :configuration, :active, :breakdowns, :academics, :grade, :cohort_count, :proficiency_band_id

  belongs_to :data_type
  has_many :data_values_to_breakdowns, inverse_of: :data_value
  has_many :breakdowns, through: :data_values_to_breakdowns, inverse_of: :data_values
  has_many :data_values_to_academics, inverse_of: :data_value
  has_many :academics, through: :data_values_to_academics, inverse_of: :data_values
  belongs_to :source, class_name: '::Gsdata::Source', inverse_of: :data_values
  belongs_to :proficiency_band, inverse_of: :data_values


  def self.from_hash(hash)
    new.tap do |obj|
      obj.value = hash['value']
      obj.state = hash['state']
      obj.school_id = hash['school_id']
      obj.district_id = hash['district_id']
      obj.data_type_id = hash['data_type_id']
      obj.configuration = hash['configuration']
      obj.grade = hash['grade']
      obj.cohort_count = hash['cohort_count']
      obj.proficiency_band_id = hash['proficiency_band_id']
      obj.active = hash['active']
      obj.source = hash['source']
      obj.data_values_to_breakdowns = hash['data_values_to_breakdowns']
      obj.data_values_to_academics = hash['data_values_to_academics']
    end
  end

# rubocop:disable Style/FormatStringToken
  def self.find_by_school_and_data_types(school, data_types, breakdown_tag_names = [], academic_tag_names = [])
    school_values.
      from(
        DataValue.school_and_data_types(school.state,
                                       school.id,
                                       data_types), :data_values)
          .with_data_types
          .with_sources
          .with_academics
          .with_academic_tags(academic_tag_names)
          .with_breakdowns
          .with_breakdown_tags(breakdown_tag_names)
          .group('data_values.id')
          .having("(breakdown_count + academic_count) < 3 OR breakdown_names like '%All students except 504 category%'")
  end

  def self.find_by_school_and_data_types_and_config(school, data_types, config, breakdown_tag_names=[])
    find_by_school_and_data_types(school,data_types, breakdown_tag_names).where(configuration: "%#{config}%")
  end

  def self.with_configuration(config)
    where(configuration: "%#{config}%")
  end

  def self.find_by_school_and_data_type_tags(school, tags, breakdown_tag_names = [])
    school_values.
      from(
        DataValue.where(school_id: school.id, state: school.state, active: 1), :data_values)
          .with_data_types
          .with_data_type_tags(tags)
          .with_sources
          .with_breakdowns
          .with_breakdown_tags(breakdown_tag_names)
          .group('data_values.id')
          .having("breakdown_count < 2 OR breakdown_names like '%All students except 504 category%'")
  end

# rubocop:enable Style/FormatStringToken
  def self.school_values
    school_values = <<-SQL
      data_values.id, data_values.value, data_values.state, data_values.school_id, data_values.district_id,
      data_values.data_type_id, data_values.configuration, data_values.cohort_count, data_values.grade, data_types.name,

  def self.school_values
    school_values = <<-SQL
      data_values.id, data_values.value, data_values.state, data_values.school_id,
      data_values.data_type_id, data_values.configuration, data_values.grade, data_values.cohort_count,
      data_values.proficiency_band_id, data_types.name,
      sources.source_name, sources.date_valid,
      group_concat(distinct breakdowns.name ORDER BY breakdowns.name) as "breakdown_names",
      group_concat(distinct bt.tag ORDER BY bt.tag) as "breakdown_t_names",
      count(distinct(breakdowns.name)) as "breakdown_count",
      group_concat(distinct academics.name ORDER BY academics.name) as "academic_names",
      group_concat(distinct act.tag ORDER BY act.tag) as "academic_t_names",
      count(distinct(academics.name)) as "academic_count",
      group_concat(distinct academics.type ORDER BY academics.type) as "academic_types"
    SQL
    select(school_values)
  end

  def self.find_by_state_and_data_types(state, data_types, breakdown_tag_names = [], academic_tag_names = [])
    state_and_district_values.
      from(
        DataValue.state_and_data_types(
          state,
          data_types
        ), :data_values)
          .with_breakdowns
          .with_breakdown_tags(breakdown_tag_names)
          .with_academics
          .with_academic_tags(academic_tag_names)
          .with_sources
          .group('data_values.id')
  end

  def self.find_by_district_and_data_types(state, district_id, data_types, breakdown_tag_names = [], academic_tag_names = [])
    state_and_district_values.
      from(
        DataValue.state_and_district_data_types(
          state,
          district_id,
          data_types
        ), :data_values)
          .with_breakdowns
          .with_breakdown_tags(breakdown_tag_names)
          .with_academics
          .with_academic_tags(academic_tag_names)
          .with_sources
          .group('data_values.id')
  end

  def self.state_and_district_values
    state_and_district_values = <<-SQL
      data_values.id, data_type_id, data_values.value, date_valid, grade, proficiency_band_id, cohort_count,
      group_concat(breakdowns.name ORDER BY breakdowns.name) as "breakdown_names",
      group_concat(academics.name ORDER BY academics.name) as "academic_names"
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
    joins('JOIN data_types on data_type_id = data_types.id')
  end

  def self.with_sources
    joins('JOIN sources on sources.id = source_id')
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

  def self.with_data_type_tags(tags)
    joins("JOIN data_type_tags on data_type_tags.data_type_id = data_types.id").where("data_type_tags.tag = ?", tags)
  end

  def self.with_breakdown_tags(breakdown_tag_names = [])
    if breakdown_tag_names.present?
      q = <<-SQL
        LEFT JOIN (select breakdown_id, tag from breakdown_tags where tag in ('#{breakdown_tag_names.join('\',\'')}')) bt
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

  def self.with_academics
    joins(<<-SQL
      LEFT JOIN data_values_to_academics
        ON data_values.id = data_values_to_academics.data_value_id
      LEFT JOIN academics
        ON academics.id = data_values_to_academics.academic_id
    SQL
    )
  end

  def self.with_academic_tags(academic_tag_names = [])
    if academic_tag_names.present?
      q = <<-SQL
        LEFT JOIN (select academic_id, tag from academic_tags where tag in ('#{academic_tag_names.join('\',\'')}')) act
        ON act.academic_id = academics.id
      SQL
    else
      q = <<-SQL
        LEFT JOIN academic_tags act
        ON act.academic_id = academics.id
      SQL
    end
    ar = joins(q)
    ar
  end

  def datatype_breakdown_year
    [data_type_id, breakdowns, date_valid]
  end

end
