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
  belongs_to :load, inverse_of: :data_values
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
  def self.find_by_school_and_data_types_with_academics(school, data_types)
    school_values_with_academics.
        from(
            DataValue.school_and_data_types(school.state,
                                            school.id,
                                            data_types), :data_values)
        .with_data_types
        .with_loads
        .with_sources
        .with_academics
        .with_academic_tags
        .with_breakdowns
        .with_breakdown_tags
        .group('data_values.id')
        .having("(breakdown_count + academic_count) < 3 OR breakdown_names like '%All students except 504 category%'")
  end

  def self.find_by_school_and_data_types_with_academics_all_students_and_grade_all(school, data_types)
    school_values_with_academics.
        from(
            DataValue.school_and_data_types(school.state,
                                            school.id,
                                            data_types), :data_values)
        .with_data_types
        .with_loads
        .with_sources
        .with_academics
        .with_academic_tags
        .with_breakdowns_for_courses
        .with_breakdown_tags
        .group('data_values.id')
        .having("((breakdown_count + academic_count) < 3 OR breakdown_names like '%All students except 504 category%') && grade='All'")
  end

  def self.find_by_school_and_data_types(school, data_types)
    school_values.
      from(
        DataValue.school_and_data_types(school.state,
                                       school.id,
                                       data_types), :data_values)
          .with_data_types
          .with_loads
          .with_sources
          .with_breakdowns
          .with_breakdown_tags
          .group('data_values.id')
          .having("breakdown_count < 2 OR breakdown_names like '%All students except 504 category%'")
  end

  def self.find_by_school_and_data_types_with_proficiency_band_name(school, data_types, tags, breakdown_tag_names = [], academic_tag_names = [] )
    school_values_with_academics_with_proficiency_band_names.
        from(
            DataValue.school_and_data_types(school.state,
                                            school.id,
                                            data_types), :data_values)
        .with_data_types
        .with_data_type_tags(tags)
        .with_loads
        .with_sources
        .with_academics
        .with_academic_tags
        .with_breakdowns
        .with_breakdown_tags
        .with_proficiency_bands
        .group('data_values.id')
        .having("(breakdown_count + academic_count) < 3 OR breakdown_names like '%All students except 504 category%'")
  end

  def self.find_by_school_and_data_types_and_config(school, data_types, config, breakdown_tag_names=[])
    find_by_school_and_data_types(school,data_types).where(configuration: "%#{config}%")
  end

  def self.with_configuration(config)
    where('data_values.configuration like ?', "%#{config}%")
  end

  def self.find_by_school_and_data_type_tags(school, tags, breakdown_tag_names = [], academic_tag_names = [])
    school_values_with_academics.
      from(
        DataValue.where(school_id: school.id, state: school.state, active: 1), :data_values)
          .with_data_types
          .with_data_type_tags(tags)
          .with_loads
          .with_sources
          .with_academics
          .with_academic_tags
          .with_breakdowns
          .with_breakdown_tags
          .group('data_values.id')
  end

# rubocop:enable Style/FormatStringToken

  def self.school_values_with_academics_with_proficiency_band_names
    school_values_with_academics = <<-SQL
      data_values.id, data_values.value, data_values.state, data_values.school_id,
      data_values.data_type_id, data_values.configuration, data_values.grade, data_values.cohort_count,
      data_values.proficiency_band_id, data_types.id as data_type_id, data_types.name, data_types.short_name,
      proficiency_bands.name as proficiency_band_name, proficiency_bands.composite_of_pro_null,
      #{LoadSource.table_name}.name as source_name, #{Load.table_name}.date_valid, #{Load.table_name}.description,
      group_concat(distinct breakdowns.name ORDER BY breakdowns.name) as "breakdown_names",
      group_concat(distinct breakdowns.id ORDER BY breakdowns.id) as "breakdown_id_list",
      group_concat(distinct bt.tag ORDER BY bt.tag) as "breakdown_tags",
      count(distinct(breakdowns.name)) as "breakdown_count",
      group_concat(distinct academics.name ORDER BY academics.name) as "academic_names",
      group_concat(distinct act.tag ORDER BY act.tag) as "academic_tags",
      count(distinct(academics.name)) as "academic_count",
      group_concat(distinct academics.type ORDER BY academics.type) as "academic_types"
    SQL
    select(school_values_with_academics)
  end

  def self.school_values
    school_values = <<-SQL
      data_values.id, data_values.value, data_values.state, data_values.school_id,
      data_values.data_type_id, data_values.configuration, data_values.grade, data_values.cohort_count,
      data_values.proficiency_band_id, data_types.name, data_types.short_name,
      #{LoadSource.table_name}.name as source_name, #{Load.table_name}.date_valid, #{Load.table_name}.description,
      group_concat(distinct breakdowns.name ORDER BY breakdowns.name) as "breakdown_names",
      group_concat(distinct bt.tag ORDER BY bt.tag) as "breakdown_tags",
      count(distinct(breakdowns.name)) as "breakdown_count"
    SQL
    select(school_values)
  end

  def self.school_values_with_academics
    school_values_with_academics = <<-SQL
      data_values.id, data_values.value, data_values.state, data_values.school_id,
      data_values.data_type_id, data_values.configuration, data_values.grade, data_values.cohort_count,
      data_values.proficiency_band_id, data_types.name,
      #{LoadSource.table_name}.name as source_name, #{Load.table_name}.date_valid, #{Load.table_name}.description,
      group_concat(distinct breakdowns.name ORDER BY breakdowns.name) as "breakdown_names",
      group_concat(distinct bt.tag ORDER BY bt.tag) as "breakdown_tags",
      count(distinct(breakdowns.name)) as "breakdown_count",
      group_concat(distinct academics.name ORDER BY academics.name) as "academic_names",
      group_concat(distinct act.tag ORDER BY act.tag) as "academic_tags",
      count(distinct(academics.name)) as "academic_count",
      group_concat(distinct academics.type ORDER BY academics.type) as "academic_types"
    SQL
    select(school_values_with_academics)
  end

  def self.find_by_state_and_data_types(state, data_types)
    state_and_district_values.
      from(
        DataValue.state_and_data_types(
          state,
          data_types
        ), :data_values)
          .with_data_types
          .with_breakdowns
          .with_breakdown_tags
          .with_academics
          .with_academic_tags
          .with_loads
          .with_sources
          .group('data_values.id')
  end

  def self.find_by_state_and_data_type_tags(state, data_type_tags)
    state_and_district_values.
      from(DataValue.state(state), :data_values)
        .with_data_types
        .with_data_type_tags(data_type_tags)
        .with_breakdowns
        .with_breakdown_tags
        .with_academics
        .with_academic_tags
        .with_loads
        .with_sources
        .group('data_values.id')
  end

  def self.find_by_district_and_data_types(state, district_id, data_types)
    state_and_district_values.
      from(
        DataValue.state_and_district_data_types(
          state,
          district_id,
          data_types
        ), :data_values)
          .with_data_types
          .with_breakdowns
          .with_breakdown_tags
          .with_academics
          .with_academic_tags
          .with_loads
          .with_sources
          .group('data_values.id')
  end

  def self.find_by_district_and_data_type_tags(state, district_id, data_type_tags)
    state_and_district_values.
      from(
        DataValue.state_and_district(
          state,
          district_id
        ), :data_values)
          .with_data_types
          .with_data_type_tags(data_type_tags)
          .with_breakdowns
          .with_breakdown_tags
          .with_academics
          .with_academic_tags
          .with_loads
          .with_sources
          .group('data_values.id')
  end

  def self.find_by_state_and_data_type_tags_with_proficiency_band_name(state, data_type_tags)
    state_and_district_values_with_proficiency_band.
        from(DataValue.state(state), :data_values)
        .with_data_types
        .with_data_type_tags(data_type_tags)
        .with_breakdowns
        .with_academics
        .with_loads
        .with_sources
        .with_proficiency_bands
        .group('data_values.id')
  end

  def self.find_by_district_and_data_type_tags_with_proficiency_band_name(state, district_id, data_type_tags)
    state_and_district_values_with_proficiency_band.
        from(
            DataValue.state_and_district(
                state,
                district_id
            ), :data_values)
        .with_data_types
        .with_data_type_tags(data_type_tags)
        .with_breakdowns
        .with_academics
        .with_loads
        .with_sources
        .with_proficiency_bands
        .group('data_values.id')
  end

  def self.state_and_district_values
    state_and_district_values = <<-SQL
      data_values.id, data_values.data_type_id, data_types.name, data_types.id as data_type_id,
      #{LoadSource.table_name}.name as source_name, #{Load.table_name}.description, data_values.value, #{Load.table_name}.date_valid, grade, proficiency_band_id, cohort_count,
      group_concat(breakdowns.name ORDER BY breakdowns.name) as "breakdown_names",
      group_concat(bt.tag ORDER BY bt.tag) as "breakdown_tags",
      group_concat(academics.name ORDER BY academics.name) as "academic_names"
    SQL
    select(state_and_district_values)
  end

  def self.state_for_data_type_id(data_type_id)
    state_only.from(DataValue.where(data_type_id: data_type_id).limit(1))
  end

  def self.state_only
    state_only = <<-SQL
      id, state
    SQL
    select(state_only)
  end

  def self.state_and_district_values_with_proficiency_band
    state_and_district_values = <<-SQL
      data_values.id, data_values.data_type_id, data_types.name, #{LoadSource.table_name}.name as source_name, #{Load.table_name}.description, 
      data_values.value, #{Load.table_name}.date_valid, grade, proficiency_band_id, 
      proficiency_bands.name as proficiency_band_name, cohort_count,
      group_concat(breakdowns.name ORDER BY breakdowns.name) as "breakdown_names",
      group_concat(breakdowns.id ORDER BY breakdowns.id) as "breakdown_id_list",
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

  def self.state(state)
    state_subquery_sql = <<-SQL
      state = ?
      AND district_id IS NULL
      AND school_id IS NULL
      AND active = 1
    SQL
    where(state_subquery_sql, state)
  end

  def self.state_and_district(state, district_id)
    district_subquery = <<-SQL
      state = ?
      AND district_id = ?
      AND school_id IS NULL
      AND active = 1
    SQL
    where(district_subquery, state, district_id)
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

  def self.with_loads
    joins('JOIN loads on loads.id = load_id')
  end

  def self.with_sources
    joins("JOIN #{LoadSource.table_name} on #{LoadSource.table_name}.id = #{Load.table_name}.source_id")
  end

  def self.with_proficiency_bands
    joins('JOIN proficiency_bands on proficiency_bands.id = proficiency_band_id')
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

  def self.with_breakdowns_for_courses
    joins(<<-SQL
      INNER JOIN data_values_to_breakdowns
        ON data_values.id = data_values_to_breakdowns.data_value_id && data_values_to_breakdowns.breakdown_id=1 
      LEFT JOIN breakdowns
        ON breakdowns.id = data_values_to_breakdowns.breakdown_id
    SQL
    )
  end

  def self.with_breakdown_tags
    joins(<<-SQL
      LEFT JOIN breakdown_tags bt
      ON bt.breakdown_id = breakdowns.id
    SQL
    )
  end


  def self.with_data_type_tags(tags)
    joins("JOIN data_type_tags on data_type_tags.data_type_id = data_types.id").where("data_type_tags.tag = ?", tags)
  end

#   def self.with_breakdown_tags(breakdown_tag_names = [])
#     if breakdown_tag_names.present?
#       q = <<-SQL
#         LEFT JOIN (select breakdown_id, tag from breakdown_tags where tag in ('#{breakdown_tag_names.join('\',\'')}')) bt
#         ON bt.breakdown_id = breakdowns.id
#       SQL
#     else
#       q = <<-SQL
#         LEFT JOIN breakdown_tags bt
#         ON bt.breakdown_id = breakdowns.id
#       SQL
#     end
#     ar = joins(q)
#     ar
#   end

  # data type predicate methods
  def summary_rating?
    data_type_id == 160
  end

  def test_scores_rating?
    data_type_id == 155
  end

  def summary_rating_test_score_weight?
    data_type_id == 176
  end

  def source_date_valid
    date_valid
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

  def self.with_academic_tags
    joins(<<-SQL
      LEFT JOIN academic_tags act
      ON act.academic_id = academics.id
    SQL
    )
  end

  def datatype_breakdown_year
    [data_type_id, breakdown_names, date_valid, try(:academic_names), grade]
  end

end
