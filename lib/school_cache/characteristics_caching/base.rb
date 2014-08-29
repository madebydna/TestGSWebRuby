class CharacteristicsCaching::Base < Cacher

  @@characteristics_data_types = Hash[CensusDataType.all.map { |f| [f.id, f] }]
  @@characteristics_data_breakdowns = Hash[CensusDataBreakdown.all.map { |f| [f.id, f] }]
  @@characteristics_descriptions = Hash[CensusDescription.all.map { |f| [f.census_data_set_id.to_s+f.state, f] }]

  cattr_accessor :characteristics_data_types, :characteristics_data_breakdowns, :characteristics_descriptions

  attr_accessor :school

  def initialize(school)
    @school = school
  end

  def characteristics_data_types
    @@characteristics_data_types
  end

  def characteristics_descriptions
    @@characteristics_descriptions
  end

  def characteristics_data_breakdowns
    @@characteristics_data_breakdowns
  end

end