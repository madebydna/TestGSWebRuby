class CensusDataType < ActiveRecord::Base
  attr_reader :description
  self.inheritance_column = nil
  octopus_establish_connection(:adapter => "mysql2", :database => "gs_schooldb")
  self.table_name = 'census_data_type'


  def name
    description
  end

  acts_as_lookup write_to_db: false, add_query_methods: false

end