# frozen_string_literal: true

require 'ruby-prof'

class TestDataValue < ActiveRecord::Base
  self.table_name = 'test_data_values'

  db_magic connection: :omni
  belongs_to :data_set
  belongs_to :proficiency_band
  belongs_to :breakdown

  has_many :data_sets

  #todo validate date format for date valid

  # test scores gsdata  proficiency is always 1
  def self.by_school(school_state, school_id)
    query = <<-SQL
    select
      tdv.value, 
      ds.state, 
      tdv.gs_id as school_id,
      tdv.grade,
      tdv.cohort_count,
      tdv.proficiency_band_id,
      b.name as breakdown_names,
      bt.tag as breakdown_tags,      
      s.name as academic_names,      
      st.tag as academic_tags,      
      ds.data_type_id, 
      ds.configuration, 
      ss.name as source, 
      ss.name as source_name, 
      ds.date_valid,
      ds.description,
      dt.name       
    from omni.test_data_values tdv 
    join omni.data_sets ds on tdv.data_set_id = ds.id
    join omni.data_types dt on dt.id = ds.data_type_id 
    join omni.data_type_tags dtt on dtt.data_type_id = ds.data_type_id
    join omni.breakdowns b on tdv.breakdown_id = b.id
    join omni.breakdown_tags bt on bt.breakdown_id = b.id 
    join omni.subjects s on tdv.subject_id = s.id    
    join omni.subject_tags st on st.subject_id = s.id    
    join omni.sources ss on ds.source_id = ss.id
    
    where ds.state = '#{school_state}' 
      and entity_type = 'school' 
      and gs_id = #{school_id} 
    and dtt.tag = 'state_test'
    and tdv.active = 1
    and proficiency_band_id = 1
    SQL

    result = self.connection.exec_query(query)
    result.map { |row| JSON.parse(row.to_json, object_class: OpenStruct) }
  end

  # test scores gsdata - district
  def self.by_district(state, district_id)
    #todo validate date format for date valid
    query = <<-SQL
        select
          tdv.value, 
          ds.state, 
          tdv.grade,
          tdv.cohort_count,
          tdv.proficiency_band_id,
          b.name as breakdown_names,
          bt.tag as breakdown_tags,      
          s.name as academic_names,      
          ds.data_type_id, 
          ds.configuration, 
          ss.name as source, 
          ss.name as source_name, 
          ds.date_valid,
          ds.description,
          dt.name     
        from omni.test_data_values tdv 
        join omni.data_sets ds on tdv.data_set_id = ds.id
        join omni.data_types dt on dt.id = ds.data_type_id 
        join omni.data_type_tags dtt on dtt.data_type_id = ds.data_type_id
        join omni.breakdowns b on tdv.breakdown_id = b.id
        join omni.breakdown_tags bt on bt.breakdown_id = b.id 
        join omni.subjects s on tdv.subject_id = s.id
        join omni.sources ss on ds.source_id = ss.id

        where ds.state = '#{state}' 
          and entity_type = 'district' 
          and gs_id = #{district_id} 
        and dtt.tag = 'state_test'
        and tdv.active = 1
        AND proficiency_band_id = 1
    SQL

    result = self.connection.exec_query(query)
    result.map { |row| JSON.parse(row.to_json, object_class: OpenStruct) }
  end

  # test scores gsdata - state
  def self.by_state(state)
    query = <<-SQL
        select
          tdv.value, 
          ds.state, 
          tdv.grade,
          tdv.cohort_count,
          tdv.proficiency_band_id,
          b.name as breakdown_names,
          bt.tag as breakdown_tags,      
          s.name as academic_names,      
          ds.data_type_id, 
          ds.configuration, 
          ss.name as source, 
          ss.name as source_name, 
          ds.date_valid,
          ds.description,
          dt.name     
        from omni.test_data_values tdv 
        join omni.data_sets ds on tdv.data_set_id = ds.id
        join omni.data_types dt on dt.id = ds.data_type_id 
        join omni.data_type_tags dtt on dtt.data_type_id = ds.data_type_id
        join omni.breakdowns b on tdv.breakdown_id = b.id
        join omni.breakdown_tags bt on bt.breakdown_id = b.id 
        join omni.subjects s on tdv.subject_id = s.id
        join omni.sources ss on ds.source_id = ss.id

        where ds.state = '#{state}' 
          and entity_type = 'state' 
        and dtt.tag = 'state_test'
        and tdv.active = 1
        AND proficiency_band_id = 1
    SQL

    result = self.connection.exec_query(query)
    result.map { |row| JSON.parse(row.to_json, object_class: OpenStruct) }
  end

  def self.feeds_by_school(school_state, school_id)
    query = <<-SQL
    select
      tdv.value, 
      ds.state, 
      tdv.gs_id as school_id,
      tdv.grade,
      tdv.cohort_count,
      tdv.proficiency_band_id,
      p.name as proficiency_band_name,
      p.composite_of_pro_null,
      b.name as breakdown_names,
      bt.tag as breakdown_tags,      
      s.name as academic_names,      
      st.tag as academic_tags,      
      ds.data_type_id, 
      ds.configuration, 
      ss.name as source, 
      ss.name as source_name, 
      ds.date_valid,
      ds.description,
      dt.name       
    from omni.test_data_values tdv 
    join omni.data_sets ds on tdv.data_set_id = ds.id
    join omni.data_types dt on dt.id = ds.data_type_id 
    join omni.data_type_tags dtt on dtt.data_type_id = ds.data_type_id
    left join omni.breakdowns b on tdv.breakdown_id = b.id
    left join omni.breakdown_tags bt on bt.breakdown_id = b.id 
    left join omni.subjects s on tdv.subject_id = s.id    
    left join omni.subject_tags st on st.subject_id = s.id    
    join omni.sources ss on ds.source_id = ss.id
    join omni.proficiency_bands p on tdv.proficiency_band_id = p.id

    where ds.state = '#{school_state}' 
      and entity_type = 'school' 
      and gs_id = #{school_id} 
      and ds.configuration like '%feeds%' 
      and dtt.tag = 'state_test'
      and tdv.active = 1
    SQL

    result = self.connection.exec_query(query)
    result.map { |row| JSON.parse(row.to_json, object_class: OpenStruct) }
  end

  def self.feeds_by_district(state, district_id)
    query = <<-SQL
    select
      tdv.value, 
      ds.state, 
      tdv.grade,
      tdv.cohort_count,
      tdv.proficiency_band_id,
      p.name as proficiency_band_name,
      p.composite_of_pro_null,
      b.name as breakdown_names,
      s.name as academic_names,      
      ds.data_type_id, 
      ds.configuration, 
      ss.name as source, 
      ss.name as source_name, 
      ds.date_valid,
      ds.description,
      dt.name       
    from omni.test_data_values tdv 
    join omni.data_sets ds on tdv.data_set_id = ds.id
    join omni.data_types dt on dt.id = ds.data_type_id 
    join omni.data_type_tags dtt on dtt.data_type_id = ds.data_type_id
    left join omni.breakdowns b on tdv.breakdown_id = b.id
    left join omni.breakdown_tags bt on bt.breakdown_id = b.id 
    left join omni.subjects s on tdv.subject_id = s.id    
    left join omni.subject_tags st on st.subject_id = s.id    
    join omni.sources ss on ds.source_id = ss.id
    join omni.proficiency_bands p on tdv.proficiency_band_id = p.id

    where ds.state = '#{state}' 
      and entity_type = 'district' 
      and gs_id = #{district_id} 
      and ds.configuration like '%feeds%' 
      and dtt.tag = 'state_test'
      and tdv.active = 1
    SQL

    result = self.connection.exec_query(query)
    result.map { |row| JSON.parse(row.to_json, object_class: OpenStruct) }
  end

  def self.feeds_by_state(state)
    query = <<-SQL
    select
      tdv.value,        
      tdv.grade,
      tdv.cohort_count,
      tdv.proficiency_band_id,
      p.name as proficiency_band_name,
      b.name as breakdown_names,
      s.name as academic_names,      
      ds.state,
      ds.data_type_id, 
      ds.configuration, 
      ds.date_valid,
      ds.description,
      ss.name as source, 
      ss.name as source_name, 
      dt.name       
    from omni.test_data_values tdv 
    join omni.data_sets ds on tdv.data_set_id = ds.id
    join omni.data_types dt on dt.id = ds.data_type_id 
    join omni.data_type_tags dtt on dtt.data_type_id = ds.data_type_id
    left join omni.breakdowns b on tdv.breakdown_id = b.id
    left join omni.breakdown_tags bt on bt.breakdown_id = b.id 
    left join omni.subjects s on tdv.subject_id = s.id    
    left join omni.subject_tags st on st.subject_id = s.id    
    join omni.sources ss on ds.source_id = ss.id
    join omni.proficiency_bands p on tdv.proficiency_band_id = p.id

    where ds.state = '#{state}' 
      and entity_type = 'state' 
      and ds.configuration like '%feeds%' 
      and dtt.tag = 'state_test'
      and tdv.active = 1
    SQL

    result = self.connection.exec_query(query)
    result.map { |row| JSON.parse(row.to_json, object_class: OpenStruct) }
  end

  def self.feeds_by_state_ar(state)
    data = TestDataValue
               .select(
                   :value,
                   :grade,
                   :cohort_count,
                   :proficiency_band_id,
                   "proficiency_bands.name as proficiency_band_name",
                   "breakdowns.name as breakdown_names",
                   "breakdowns.id as breakdown_id_list",
                   "subjects.name as academic_names",
                   "data_sets.state",
                   "data_sets.data_type_id",
                   "data_sets.configuration",
                   "data_sets.date_valid",
                   "data_sets.description",
                   "sources.name as source",
                   "sources.name as source_name",
                   "data_types.name"
               )
               .joins(:data_set).where(data_sets: { state: state, configuration: 'feeds' })
               .joins("join data_types on data_types.id = data_sets.data_type_id ")
               .joins("join data_type_tags on data_type_tags.data_type_id = data_sets.data_type_id").where(data_type_tags: { tag: 'state_test' })
               .joins("left join breakdowns on test_data_values.breakdown_id = breakdowns.id")
               .joins("left join breakdown_tags on breakdown_tags.breakdown_id = breakdowns.id")
               .joins("left join subjects on subjects.id = test_data_values.subject_id")
               .joins("left join subject_tags on subjects.id = subject_tags.subject_id")
               .joins("join sources on sources.id = data_sets.source_id")
               .joins(:proficiency_band)
               .where(entity_type: 'state', active: 1)
    data
  end

end