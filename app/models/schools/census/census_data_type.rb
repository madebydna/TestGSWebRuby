class CensusDataType < ActiveRecord::Base
  self.table_name = 'census_data_type'
  self.inheritance_column = nil

  db_magic :connection => :gs_schooldb

  def self.reverse_lookup(names)
    names = Array(names)
    data_types = Rails.cache.fetch("CensusDataType/all", expires_in: 5.minutes) do
      all
    end

    data_types.select! { |data_type| names.include?(data_type.description) }

    # Sort in the same order the names were passed in
    data_types.sort_by { |data_type| names.index(data_type[:description]) }
  end
end