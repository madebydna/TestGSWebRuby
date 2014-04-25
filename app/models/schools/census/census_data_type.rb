class CensusDataType < ActiveRecord::Base
  self.table_name = 'census_data_type'
  self.inheritance_column = nil

  db_magic :connection => :gs_schooldb

  def self.all_data_types
    data_types = Rails.cache.fetch("CensusDataType/all", expires_in: 5.minutes) do
      all
    end
  end

  def self.reverse_lookup(names)
    names = Array(names)

    data_types = all_data_types.clone
    if names.present?
      data_types = all_data_types.select do |data_type|
        names.include?(data_type.description)
      end
    end

    # Sort in the same order the names were passed in
    data_types.sort_by { |data_type| names.index(data_type[:description]) }
  end

  def self.lookup_table(ids = nil)
    ids = Array(ids)

    data_types = all_data_types.clone
    if ids.present?
      data_types = all_data_types.select do |data_type|
        ids.include?(data_type.id)
      end
    end

    data_types.inject({}) { |hash, dt| hash[dt.id] = dt[:description]; hash }
  end

  def self.description_for_id(id)
    all_data_types.find { |dt| id == dt.id }.description
  end

  def self.description_id_hash
    Rails.cache.fetch("CensusDataType/description_id_hash", expires_in: 5.minutes) do
      all.inject({}) { |hash, cdt| hash[cdt.description] = cdt.id; hash }
    end
  end

  def self.data_type_ids(data_type_names_or_ids)
    data_type_names_or_ids = Array.wrap(data_type_names_or_ids)
    if data_type_names_or_ids.first.to_i == 0
      data_type_ids = reverse_lookup(data_type_names_or_ids).map(&:id)
      data_type_ids.uniq!
    else
      data_type_ids = data_type_names_or_ids
    end
    data_type_ids
  end

end