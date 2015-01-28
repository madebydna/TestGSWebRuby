class CharacteristicsCaching::Base < Cacher

  @@characteristics_data_types = Hash[CensusDataType.all.map { |f| [f.id, f] }]
  @@characteristics_data_breakdowns = Hash[CensusDataBreakdown.all.map { |f| [f.id, f] }]
  @@characteristics_descriptions = Hash[CensusDescription.all.map { |f| [f.census_data_set_id.to_s+f.state, f] }]

  cattr_accessor :characteristics_data_types, :characteristics_data_breakdowns, :characteristics_descriptions

  def characteristics_data_types
    @@characteristics_data_types
  end

  def configured_characteristics_data_types
    Hash[CensusDataConfigEntry.on_db(school.shard).all.map { |f| [f.data_type_id, f] }]
  end

  def characteristics_descriptions
    @@characteristics_descriptions
  end

  def characteristics_data_breakdowns
    @@characteristics_data_breakdowns
  end

  def self.listens_to?(data_type)
    :census == data_type
  end
end