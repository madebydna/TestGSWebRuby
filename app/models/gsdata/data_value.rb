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

  def self.load_ids(loads)
    loads&.map(&:id)&.uniq
  end

  def self.datatype_breakdown_year(obj)
    [obj.data_type_id, obj.breakdown_names, obj.date_valid, obj.academic_names, obj.grade]
  end

###############################################################################################

########################################### School Queries ####################################

###############################################################################################

# ratings
# rubocop:disable Style/FormatStringToken
  def self.find_by_school_and_data_types_with_academics(school, data_types, configuration= default_configuration)
    school_load_ids = filter_query(school.state, nil, school.id).pluck(:load_id).uniq
    a = []
    if school_load_ids.present?
      loads = Load.data_type_ids_to_loads(data_types, configuration, school_load_ids )
      if loads.present?
        dvs = school_values_with_academics.
            from(
                DataValue.filter_query(school.state,
                                      nil,
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
    end
    a
  end

  # courses
  def self.find_by_school_and_data_types_with_academics_all_students_and_grade_all(school, data_types, configuration= default_configuration)
    loads = Load.data_type_ids_to_loads(data_types, configuration )
    dvs = school_values_with_academics.
        from(
            DataValue.filter_query(school.state,
                                  nil,
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
        DataValue.filter_query(school.state,
                                        nil,
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
        DataValue.filter_query(school.state,
                               nil,
                               school.id,
                               load_ids(loads),
                               true), :data_values)
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
            DataValue.filter_query(school.state,
                                   nil,
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

############################################ Select fields for school queries ########################################

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

###############################################################################################

################################ State and District Queries ####################################

###############################################################################################

  # gsdata - state
  def self.find_by_state_and_data_types(state, data_types, configuration= default_configuration)
    loads = Load.data_type_ids_to_loads(data_types, configuration )
    dvs = state_and_district_values.
      from(
        DataValue.filter_query(state,
                                nil,
                                nil,
                                load_ids(loads)), :data_values)
          .with_breakdowns
          .with_breakdown_tags
          .with_academics
          .with_academic_tags
          .group('data_values.id')
    GsdataCaching::LoadDataValue.new(loads, dvs).merge
  end

  # test scores gsdata - state
  def self.find_by_state_and_data_type_tags_and_proficiency_is_one(state, data_type_tags, configuration= default_configuration)
    state_load_ids = filter_query(state).pluck(:load_id).uniq
    a = []
    if state_load_ids.present?
      loads = Load.data_type_tags_to_loads(data_type_tags, configuration, state_load_ids)
      if loads.present?
        dvs = state_and_district_values.
          from(
                DataValue.filter_query(state,
                                       nil,
                                       nil,
                                       load_ids(loads),
                                       true), :data_values)
            .with_breakdowns
            .with_breakdown_tags
            .with_academics
            .with_academic_tags
            .group('data_values.id')
        a = GsdataCaching::LoadDataValue.new(loads, dvs).merge
      end
    end
    a
  end

  # gsdata - district
  def self.find_by_district_and_data_types(state, district_id, data_types, configuration= default_configuration)
    loads = Load.data_type_ids_to_loads(data_types, configuration)
    dvs = state_and_district_values.
      from(
        DataValue.filter_query(
                                state,
                                district_id,
                                nil,
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
    subset_load_ids = filter_query(state, district_id).pluck(:load_id).uniq
    a = []
    if subset_load_ids.present?
      loads = Load.data_type_tags_to_loads(data_type_tags, configuration, subset_load_ids)
      if loads.present?
        dvs = state_and_district_values.
          from(
            DataValue.filter_query(state,
                                    district_id,
                                    nil,
                                    load_ids(loads),
                                    true), :data_values)
              .with_breakdowns
              .with_breakdown_tags
              .with_academics
              .with_academic_tags
              .group('data_values.id')
        a = GsdataCaching::LoadDataValue.new(loads, dvs).merge
      end
    end
    a
  end

  # test scores gsdata - state - feeds
  def self.find_by_state_and_data_type_tags_with_proficiency_band_name(state, data_type_tags, configuration= default_configuration)
    loads = Load.data_type_tags_to_loads(data_type_tags, configuration)
    dvs = state_and_district_values_with_proficiency_band.
        from(
            DataValue.filter_query(
                state,
                nil,
                nil,
                load_ids(loads)), :data_values)
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
            DataValue.filter_query(
                state,
                district_id,
                nil,
                load_ids(loads)
            ), :data_values)
        .with_breakdowns
        .with_academics
        .with_proficiency_bands
        .group('data_values.id')
    GsdataCaching::LoadDataValue.new(loads, dvs).merge
  end

############################################ Select fields State and District ########################################

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

############################################ Where filters ########################################
#

  def self.filter_query(state, district_id = nil, school_id = nil, load_ids = nil, proficiency = nil)
    q = []
    q  << build_state_clause(state)
    q  << build_district_clause(district_id)
    q  << build_school_clause(school_id)
    q  << build_load_ids_clause(load_ids)
    q  << build_proficiency_band_one_clause(proficiency)
    q  << build_active_clause

    school_subquery_sql = q.compact.join(' AND ')
    where(school_subquery_sql)
  end

  def self.build_state_clause(state)
    "state = '#{state}'"
  end

  def self.build_district_clause(district)
    if district.nil?
      'district_id IS NULL'
    elsif district.present?
      "district_id = '#{district}'"
    end
  end

  def self.build_school_clause(school)
    if school.nil?
      'school_id IS NULL'
    elsif school.present?
      "school_id = '#{school}'"
    end
  end

  def self.build_load_ids_clause(load_ids)
    if load_ids.present?
      "load_id IN (#{load_ids.join(',')})"
    end
  end

  def self.build_active_clause
    'active = 1'
  end

  def self.build_proficiency_band_one_clause(proficiency)
    'proficiency_band_id = 1' if proficiency.present?
  end


#####################################    Table Joins   #####################################

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

end
