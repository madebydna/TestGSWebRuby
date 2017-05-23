class CharacteristicsCaching::Base < Cacher

  def self.clear_rails_caches
    Rails.cache.delete('CharacteristicsCaching::Base.characteristics_descriptions');
  end

  def self.characteristics_data_types
    Rails.cache.fetch('CharacteristicsCaching::Base.characteristics_data_types', expires_in: 2.weeks) do
      Hash[CensusDataType.all.map { |f| [f.id, f] }]
    end
  end
  def characteristics_data_types
    self.class.characteristics_data_types
  end

  def configured_characteristics_data_types
    Hash[CensusDataConfigEntry.on_db(school.shard).all.map { |f| [f.data_type_id, f] }]
  end

  def self.characteristics_descriptions
    Rails.cache.fetch('CharacteristicsCaching::Base.characteristics_descriptions', expires_in: 2.weeks) do
      Hash[CensusDescription.all.map { |f| [f.census_data_set_id.to_s+f.state, f] }]
    end
  end

  def self.characteristics_data_breakdowns
    Rails.cache.fetch('CharacteristicsCaching::Base.characteristics_data_breakdowns', expires_in: 2.weeks) do
      Hash[CensusDataBreakdown.all.map { |f| [f.id, f] }]
    end
  end

  def self.listens_to?(data_type)
    :census == data_type
  end
end
