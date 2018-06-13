# frozen_string_literal: true

module GSdataInsertStatement
  def self.build(row,source)
    if row[:entity_level] == 'source'
        "insert into gsdata.sources (source_name,date_valid,notes,description) values ('#{source[:source_name]}','#{source[:date_valid]}','#{row[:notes]}','#{row[:description]}');\n"
    else
        "insert into gsdata.data_values (value,state,district_id,school_id,data_type_id,source_id,cohort_count,grade,proficiency_band_id) values ('#{row[:value_float]}','#{source[:state].upcase}',#{row[:district_id]},#{row[:school_id]},#{row[:gsdata_test_data_type_id]},(select id from gsdata.sources where source_name = '#{source[:source_name]}' and date_valid = '#{source[:date_valid]}' and notes = '#{row[:notes]}'),#{row[:number_tested]},'#{row[:grade]}',#{row[:proficiency_band_gsdata_id]});
    insert into gsdata.data_values_to_breakdowns (data_value_id,breakdown_id) values ((select max(id) from gsdata.data_values),#{row[:breakdown_gsdata_id]});
    insert into gsdata.data_values_to_academics (data_value_id,academic_id) values ((select max(id) from gsdata.data_values),#{row[:academic_gsdata_id]});\n";
    end
  end
end


