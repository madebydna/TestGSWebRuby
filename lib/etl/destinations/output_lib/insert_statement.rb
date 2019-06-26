# frozen_string_literal: true

module InsertStatement
  def self.build(row,source)
    if row[:entity_level] == 'source'
        "insert into omni.data_sets (source_id,data_type_id,state,date_valid,configuration,notes,description) values ('#{source[:source_id]}',#{row[:test_data_type_id]},'#{source[:state].upcase}','#{row[:date_valid]}','none','#{::Mysql2::Client.escape(row[:notes])}','#{::Mysql2::Client.escape(row[:description])}');\n"
    else
        "insert into omni.test_data_values (entity_type,gs_id,data_set_id,value,cohort_count,breakdown_id,subject_id,grade,proficiency_band_id) values ('#{row[:entity_type]}','#{row[:gs_id]}',(select max(id) from omni.data_sets where source_id = #{source[:source_id]} and data_type_id = #{row[:test_data_type_id]} and date_valid = '#{row[:date_valid]}'),'#{row[:value]}',#{row[:number_tested]},#{row[:breakdown_id]},#{row[:subject_id]},'#{row[:grade]}',#{row[:proficiency_band_id]});\n";
    end
  end
end