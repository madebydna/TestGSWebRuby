class CensusDescription < ActiveRecord::Base
  self.inheritance_column = nil

  # This will cause all queries to namespace the table under the database name
  # This allows models of sharded tables to join with this table
  def self.table_name_prefix
    "#{Rails.configuration.database_configuration["#{Rails.env}"]['gs_schooldb']['database']}."
  end
  self.table_name = self.table_name_prefix + 'census_description'

  db_magic :connection => :gs_schooldb

  attr_accessible :id, :census_data_set_id, :state, :school_type, :source, :description, :type

  # belongs_to :census_data_set, :class_name => 'CensusDataSet', foreign_key: 'census_data_set_id'

  #alias_method :data_set_id, :census_data_set_id

  def self.for_data_sets_and_school(data_sets, school)
    data_set_ids = Array(data_sets).map(&:id)
    CensusDescription.where(state: school.state, school_type: school.type, census_data_set_id: data_set_ids)
  end

end