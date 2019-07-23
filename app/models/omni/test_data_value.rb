# frozen_string_literal: true

require 'ruby-prof'

class TestDataValue < ActiveRecord::Base
  self.table_name = 'test_data_values'

  db_magic connection: :omni

  DATA_TYPE_TAGS = %w(state_test)

  # test scores gsdata!!!!  proficiency is always 1
  def self.find_by_school_and_data_type_tags(school, tags, configuration = DataValue.default_configuration)
    query = <<-SQL
    select * from omni.test_data_values tdv 
    join omni.data_sets ds on tdv.data_set_id = ds.id 
    join omni.proficiency_bands pb on tdv.proficiency_band_id = pb.id
    join omni.data_type_tags dtt on dtt.data_type_id = ds.data_type_id
    join omni.breakdowns b on tdv.breakdown_id = b.id 
    join omni.subjects s on tdv.subject_id = s.id
    where ds.state = '#{school.state}' and entity_type = 'school' and gs_id = #{school.id} 
    and tag = 'state_test' and configuration = 'feeds'
    SQL

    result = self.connection.exec_query(query)
    result.map {|row| JSON.parse(row.to_json, object_class: OpenStruct)}
  end

  def self.test_scores(school, tags, configuration=DataValue.default_configuration)
    # loads = Load.data_type_tags_to_loads(tags, configuration )
    # dvs = school_values_with_academics.
    #     from(
    #         DataValue.filter_query(school.state,
    #                                nil,
    #                                school.id,
    #                                load_ids(loads),
    #                                true), :data_values)
    #           .with_academics
    #           .with_academic_tags
    #           .with_breakdowns
    #           .with_breakdown_tags
    #           .with_proficiency_bands
    #           .group('data_values.id')
    # GsdataCaching::LoadDataValue.new(loads, dvs).merge

    query = <<-SQL
    select * from omni.test_data_values tdv 
    join omni.data_sets ds on tdv.data_set_id = ds.id 
    join omni.proficiency_bands pb on tdv.proficiency_band_id = pb.id
    join omni.data_type_tags dtt on dtt.data_type_id = ds.data_type_id
    join omni.breakdowns b on tdv.breakdown_id = b.id 
    join omni.subjects s on tdv.subject_id = s.id
    where ds.state = '#{school.state}' and entity_type = 'school' and gs_id = #{school.id} 
    and tag = 'state_test' and configuration = 'feeds'
    SQL

    result = self.connection.exec_query(query)
    result.map {|row| JSON.parse(row.to_json, object_class: OpenStruct)}
  end



end
