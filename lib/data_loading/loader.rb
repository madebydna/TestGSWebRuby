class Loader

  attr_accessor :data_type, :updates, :source

  ACTION_DISABLE = 'disable'
  ACTION_BUILD_CACHE = 'build_cache'

  def initialize(data_type, updates, source)
    @data_type = data_type
    @updates = updates
    @source = source
  end

  def self.census_data_type?(datatype)
    CensusLoading::Base.census_data_types.keys.any? { |cdt| datatype.casecmp(cdt) == 0 } || datatype.to_s.downcase == 'census'
  end

  def self.esp_data_type?(datatype)
    datatype.to_s.downcase == 'osp'
  end

  def self.determine_loading_class(data_type)
    if census_data_type?(data_type)
      CensusLoading::Loader
    elsif data_type == 'newsletter'
      # ... just an example of how to extend
    elsif esp_data_type?(data_type)
      EspResponseLoading::Loader
    else
      EspResponseLoading::Loader
    end
  end
end