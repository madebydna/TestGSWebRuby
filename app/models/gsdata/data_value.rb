# frozen_string_literal: true

class DataValue < ActiveRecord::Base
  self.table_name = 'data_values'

  db_magic connection: :gsdata

  attr_accessible :value, :state, :school_id, :district_id, :active, :breakdowns, :academics, :grade,
                  :cohort_count, :proficiency_band_id, :load_id

  has_many :data_values_to_breakdowns, inverse_of: :data_value
  has_many :breakdowns, through: :data_values_to_breakdowns, inverse_of: :data_values
  has_many :data_values_to_academics, inverse_of: :data_value
  has_many :academics, through: :data_values_to_academics, inverse_of: :data_values
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

  def self.default_configuration
    %w(none web)
  end

  # ratings
# rubocop:disable Style/FormatStringToken
  def self.find_by_school_and_data_types_with_academics(school, data_types, configuration= default_configuration)
    subset_load_ids = state_and_school_load_ids.school_and_data_types_no_load(school.state, school.id).pluck(:load_id)
    a = []
    # require 'pry'; binding.pry;
    if subset_load_ids.present?
      loads = data_type_ids_to_loads(data_types, configuration, subset_load_ids )
      dvs = school_values_with_academics.
          from(
              DataValue.school_and_data_types(school.state,
                                              school.id,
                                              load_ids(loads)), :data_values)
          .with_academics
          .with_academic_tags
          .with_breakdowns
          .with_breakdown_tags
          .group('data_values.id')
          .having("(breakdown_count + academic_count) < 3 OR breakdown_names like '%All students except 504 category%'")
      a = GsdataCaching::LoadDataValue.new(loads, dvs).merge
    end
    a
  end

  # courses
  def self.find_by_school_and_data_types_with_academics_all_students_and_grade_all(school, data_types, configuration= default_configuration)
    loads = Load.data_type_ids_to_loads(data_types, configuration )
    dvs = school_values_with_academics.
        from(
            DataValue.school_and_data_types(school.state,
                                            school.id,
                                            load_ids(loads)), :data_values)
        .with_academics
        .with_academic_tags
        .with_breakdowns_for_courses
        .with_breakdown_tags
        .group('data_values.id')
        .having("((breakdown_count + academic_count) < 3 OR breakdown_names like '%All students except 504 category%') && grade='All'")
    GsdataCaching::LoadDataValue.new(loads, dvs).merge
  end

  # gsdata
  def self.find_by_school_and_data_types(school, data_types, configuration= default_configuration)
    loads = Load.data_type_ids_to_loads(data_types, configuration)
    dvs = school_values.
      from(
        DataValue.school_and_data_types(school.state,
                                        school.id,
                                        load_ids(loads)), :data_values)
          .with_breakdowns
          .with_breakdown_tags
          .group('data_values.id')
          .having("breakdown_count < 2 OR breakdown_names like '%All students except 504 category%'")
    GsdataCaching::LoadDataValue.new(loads, dvs).merge
  end

  # test scores gsdata!!!!  proficiency is always 1
  def self.find_by_school_and_data_type_tags_proficiency_is_one(school, tags, configuration=default_configuration, breakdown_tag_names = [], academic_tag_names = [])
    loads = Load.data_type_tags_to_loads(tags, configuration )
    dvs = school_values_with_academics.
      from(
        DataValue.school_and_data_types_and_proficiency(school.state,
                                        school.id,
                                        load_ids(loads)), :data_values)
          .with_academics
          .with_academic_tags
          .with_breakdowns
          .with_breakdown_tags
          .with_proficiency_bands
          .group('data_values.id')
    GsdataCaching::LoadDataValue.new(loads, dvs).merge
  end

# test scores gsdata - feeds!!!! all proficiencies
  def self.find_by_school_and_data_type_tags(school, tags, configuration=default_configuration, breakdown_tag_names = [], academic_tag_names = [])
    loads = Load.data_type_tags_to_loads(tags, configuration )
    dvs = school_values_with_academics_with_proficiency_band_names.
        from(
            DataValue.school_and_data_types(school.state,
                                            school.id,
                                            load_ids(loads)), :data_values)
              .with_academics
              .with_academic_tags
              .with_breakdowns
              .with_breakdown_tags
              .with_proficiency_bands
              .group('data_values.id')
    GsdataCaching::LoadDataValue.new(loads, dvs).merge
  end
# rubocop:enable Style/FormatStringToken

  def self.school_values_with_academics_with_proficiency_band_names
    school_values_with_academics = <<-SQL
      data_values.id, data_values.value, data_values.state, data_values.school_id, data_values.load_id,
      data_values.grade, data_values.cohort_count,data_values.proficiency_band_id, 
      proficiency_bands.name as proficiency_band_name, proficiency_bands.composite_of_pro_null,
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
      data_values.id, data_values.value, data_values.state, data_values.school_id, data_values.load_id,
      data_values.grade, data_values.cohort_count, data_values.proficiency_band_id,
      group_concat(distinct breakdowns.name ORDER BY breakdowns.name) as "breakdown_names",
      group_concat(distinct bt.tag ORDER BY bt.tag) as "breakdown_tags",
      count(distinct(breakdowns.name)) as "breakdown_count"
    SQL
    select(school_values)
  end

  def self.state_and_school_load_ids
    state_and_school_load_ids = <<-SQL
      distinct load_id
    SQL
    select(state_and_school_load_ids)
  end

  def self.school_values_with_academics
    school_values_with_academics = <<-SQL
      data_values.id, data_values.value, data_values.state, data_values.school_id, data_values.load_id,
      data_values.grade, data_values.cohort_count, data_values.proficiency_band_id,
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

  # gsdata - state
  def self.find_by_state_and_data_types(state, data_types, configuration= default_configuration)
    loads = Load.data_type_ids_to_loads(data_types, configuration )
    dvs = state_and_district_values.
      from(
        DataValue.state_and_data_types(
          state,
          load_ids(loads)
        ), :data_values)
          .with_breakdowns
          .with_breakdown_tags
          .with_academics
          .with_academic_tags
          .group('data_values.id')
    GsdataCaching::LoadDataValue.new(loads, dvs).merge
  end

  # test scores gsdata - state
  def self.find_by_state_and_data_type_tags_and_proficiency_is_one(state, data_type_tags, configuration= default_configuration)
    loads = Load.data_type_tags_to_loads(data_type_tags, configuration)
    dvs = state_and_district_values.
      from(DataValue.state_and_data_type_tags_and_proficiency_is_one(state, load_ids(loads)), :data_values)
        .with_breakdowns
        .with_breakdown_tags
        .with_academics
        .with_academic_tags
        .group('data_values.id')
    GsdataCaching::LoadDataValue.new(loads, dvs).merge
  end

  # gsdata - district
  def self.find_by_district_and_data_types(state, district_id, data_types, configuration= default_configuration)
    loads = Load.data_type_ids_to_loads(data_types, configuration )
    dvs = state_and_district_values.
      from(
        DataValue.state_and_district_and_data_types(
          state,
          district_id,
          load_ids(loads)
        ), :data_values)
          .with_breakdowns
          .with_breakdown_tags
          .with_academics
          .with_academic_tags
          .group('data_values.id')
    GsdataCaching::LoadDataValue.new(loads, dvs).merge
  end

  # test scores gsdata - district
  def self.find_by_district_and_data_type_tags_and_proficiency_is_one(state, district_id, data_type_tags, configuration= default_configuration)
    loads = Load.data_type_tags_to_loads(data_type_tags, configuration)
    dvs = state_and_district_values.
      from(
        DataValue.state_and_district_and_data_types_and_proficiency_is_one(
          state,
          district_id,
          load_ids(loads)
        ), :data_values
      )
          .with_breakdowns
          .with_breakdown_tags
          .with_academics
          .with_academic_tags
          .group('data_values.id')
    GsdataCaching::LoadDataValue.new(loads, dvs).merge
  end

  # test scores gsdata - state - feeds
  def self.find_by_state_and_data_type_tags_with_proficiency_band_name(state, data_type_tags, configuration= default_configuration)
    loads = Load.data_type_tags_to_loads(data_type_tags, configuration)
    dvs = state_and_district_values_with_proficiency_band.
        from(DataValue.state_and_data_type_tags(state, load_ids(loads)), :data_values)
        .with_breakdowns
        .with_academics
        .with_proficiency_bands
        .group('data_values.id')
    GsdataCaching::LoadDataValue.new(loads, dvs).merge
  end

  # test scores gsdata - district - feeds
  def self.find_by_district_and_data_type_tags_with_proficiency_band_name(state, district_id, data_type_tags, configuration= default_configuration)
    loads = Load.data_type_tags_to_loads(data_type_tags, configuration)
    dvs = state_and_district_values_with_proficiency_band.
        from(
            DataValue.state_and_district_and_data_types(
                state,
                district_id,
                load_ids(loads)
            ), :data_values)
        .with_breakdowns
        .with_academics
        .with_proficiency_bands
        .group('data_values.id')
    GsdataCaching::LoadDataValue.new(loads, dvs).merge
  end

  def self.state_and_district_values
    state_and_district_values = <<-SQL
      data_values.id, data_values.load_id, data_values.state,
      data_values.value, grade, proficiency_band_id, cohort_count,
      group_concat(breakdowns.name ORDER BY breakdowns.name) as "breakdown_names",
      group_concat(bt.tag ORDER BY bt.tag) as "breakdown_tags",
      group_concat(academics.name ORDER BY academics.name) as "academic_names"
    SQL
    select(state_and_district_values)
  end

  def self.state_and_district_values_with_proficiency_band
    state_and_district_values_with_proficiency_band = <<-SQL
      data_values.id, data_values.load_id, data_values.value, data_values.state, grade, proficiency_band_id, 
      proficiency_bands.name as proficiency_band_name, cohort_count,
      group_concat(breakdowns.name ORDER BY breakdowns.name) as "breakdown_names",
      group_concat(breakdowns.id ORDER BY breakdowns.id) as "breakdown_id_list",
      group_concat(academics.name ORDER BY academics.name) as "academic_names"
    SQL
    select(state_and_district_values_with_proficiency_band)
  end

  def self.school_and_data_types(state, school_id, load_ids)
    school_subquery_sql = <<-SQL
      state = ?
      AND district_id IS NULL
      AND school_id = ?
      AND load_id IN (?)
      AND active = 1
    SQL
    where(school_subquery_sql, state, school_id, load_ids)
  end

  def self.school_and_data_types_no_load(state, school_id)
    school_subquery_sql = <<-SQL
      state = ?
      AND district_id IS NULL
      AND school_id = ?
      AND active = 1
    SQL
    where(school_subquery_sql, state, school_id)
  end

  def self.school_and_data_types_and_proficiency(state, school_id, load_ids)
    school_subquery_sql = <<-SQL
      state = ?
      AND district_id IS NULL
      AND school_id = ?
      AND load_id IN (?)
      AND active = 1
      AND proficiency_band_id = 1
    SQL
    where(school_subquery_sql, state, school_id, load_ids)
  end

  def self.state_and_data_types(state, load_ids)
    state_subquery_sql = <<-SQL
      state = ?
      AND district_id IS NULL
      AND school_id IS NULL
      AND load_id IN (?)
      AND active = 1
    SQL
    where(state_subquery_sql, state, load_ids)
  end

  # def self.state(state)
  #   state_subquery_sql = <<-SQL
  #     state = ?
  #     AND district_id IS NULL
  #     AND school_id IS NULL
  #     AND active = 1
  #   SQL
  #   where(state_subquery_sql, state)
  # end

  def self.state_and_data_type_tags_and_proficiency_is_one(state, load_ids)
    state_subquery_sql = <<-SQL
      state = ?
      AND district_id IS NULL
      AND school_id IS NULL
      AND load_id IN (?)
      AND active = 1
      AND proficiency_band_id = 1
    SQL
    where(state_subquery_sql, state, load_ids)
  end

  def self.state_and_data_type_tags(state, load_ids)
    state_subquery_sql = <<-SQL
      state = ?
      AND district_id IS NULL
      AND school_id IS NULL
      AND load_id IN (?)
      AND active = 1
    SQL
    where(state_subquery_sql, state, load_ids)
  end

  # def self.state_and_district(state, district_id)
  #   district_subquery = <<-SQL
  #     state = ?
  #     AND district_id = ?
  #     AND school_id IS NULL
  #     AND active = 1
  #   SQL
  #   where(district_subquery, state, district_id)
  # end

  def self.state_and_district_and_data_types(state, district_id, load_ids)
    district_subquery = <<-SQL
      state = ?
      AND district_id = ?
      AND school_id IS NULL
      AND load_id IN (?)
      AND active = 1
    SQL
    where(district_subquery, state, district_id,  load_ids)
  end

  def self.state_and_district_and_data_types_and_proficiency_is_one(state, district_id, load_ids)
    district_subquery = <<-SQL
      state = ?
      AND district_id = ?
      AND school_id IS NULL
      AND load_id IN (?)
      AND active = 1
      AND proficiency_band_id = 1
    SQL
    where(district_subquery, state, district_id, load_ids)
  end

  # def self.data_type_ids_to_loads(data_type_ids, configuration= default_configuration)
  #   Load.data_type_ids_to_loads(data_type_ids, configuration)
  #   # Load.load_and_source_and_data_type.from(Load.with_data_type_ids(data_type_ids).with_configuration(configuration), :loads).with_data_types
  # end
  #
  # def self.data_type_tags_to_loads(tags, configuration = default_configuration)
  #   Load.data_type_tags_to_loads(tags, configuration)
  #   # Load.with_data_types.with_data_type_tags(tags).with_configuration(configuration)
  # end

  # def self.data_type_ids_and_tags_to_loads(data_type_ids, tags, configuration = default_configuration)
  #   Load.with_data_types.with_data_type_ids(data_type_ids).with_data_type_tags(tags).with_configuration(configuration)
  # end

  def self.load_ids(loads)
    loads&.map(&:id)
  end

  # def self.load_ids_dv(loads)
  #   loads&.map(&:load_id)
  # end

  # def self.load_source_name(load)
  #   load&.load_source&.name
  # end






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


  # def self.with_data_type_tags(tags)
  #   joins("JOIN data_type_tags on data_type_tags.data_type_id = data_types.id").where("data_type_tags.tag = ?", tags)
  # end

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

  # def source_date_valid
  #   date_valid
  # end

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

  def self.datatype_breakdown_year(obj)
    [obj.data_type_id, obj.breakdown_names, obj.date_valid, obj.academic_names, obj.grade]
  end

  def self.data_type_ids_to_loads(data_type_ids, configuration, subset_load_ids )
    # config = configuration.is_a?(Array) ? configuration.join(',') : configuration
    dtis = data_type_ids.join(',')
    sli = subset_load_ids.join(',')
    # hash_key = dtis + config + sli
    # @_data_type_ids_to_loads ||= {}
    # @_data_type_ids_to_loads[hash_key] ||= begin
      find_by_sql("select loads.id,
        loads.data_type_id,
        loads.configuration,
        loads.date_valid,
        loads.description,
        (sources_new.name) as 'source_name',
        (data_types.name) as 'data_type_name',
        (data_types.short_name) as 'data_type_short_name'
        from loads, sources_new, data_types
        where loads.data_type_id = data_types.id and loads.source_id = sources_new.id
        and loads.data_type_id in (#{dtis})
        and loads.id in (#{sli})
        and (#{with_configuration_new(configuration)})")
    # end
  end

  def self.with_configuration_new(config)
    q = "loads.configuration like '%#{config}%'"
    if config.is_a?(Array)
      q =''
      config.each_with_index  do | c, i |
        if i > 0
          q += ' or '
        end
        q += "loads.configuration like '%#{c}%'"
      end
    end
    q
  end

end
