# frozen_string_literal: true

require 'ruby-prof'

class TestDataValue < ActiveRecord::Base
  self.table_name = 'test_data_values'

  db_magic connection: :omni

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
    result.map {|row| JSON.parse(row.to_json, object_class: OpenStruct)}
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
    result.map {|row| JSON.parse(row.to_json, object_class: OpenStruct)}
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
    result.map {|row| JSON.parse(row.to_json, object_class: OpenStruct)}
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
      and ds.configuration like '%feeds%' 
      and dtt.tag = 'state_test'
      and tdv.active = 1
    SQL

    result = self.connection.exec_query(query)
    result.map {|row| JSON.parse(row.to_json, object_class: OpenStruct)}
  end

end