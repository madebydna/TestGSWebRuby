class CensusDataType < ActiveRecord::Base
  self.table_name = 'census_data_type'
  self.inheritance_column = nil

  db_magic :connection => :gs_schooldb

  def self.reverse_lookup(names)
    names = Array(names)
    data_types = Rails.cache.fetch("CensusDataType/#{names.join}", expires_in: 1.hour) do
      where(description: Array(names)).all
    end

    # Sort in the same order the names were passed in
    data_types.sort_by { |data_type| names.index(data_type[:description]) }
  end
end