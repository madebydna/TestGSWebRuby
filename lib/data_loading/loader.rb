class Loader

  attr_accessor :data_type, :updates, :source

  ACTION_DISABLE = 'disable'
  ACTION_BUILD_CACHE = 'build_cache'
  ACTION_NO_CACHE_BUILD = 'no_cache_rebuild'

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

  def self.determine_loading_class(source ,data_type)
    # The esp loader class write happens only from Form UI now
    if  source == 'osp_form'
        if census_data_type?(data_type)
          CensusLoading::Loader
        elsif data_type == 'school_data'
          SchoolLoading::Loader
        else
          EspResponseLoading::Loader
        end
    elsif source !='osp_form'
    if census_data_type?(data_type)
      CensusLoading::Loader
    elsif data_type == 'newsletter'
      # ... just an example of how to extend
    elsif data_type == 'school_reviews'
      ReviewLoading::Loader
    elsif data_type == 'school_media'
      SchoolMediaLoading::Loader
    elsif esp_data_type?(data_type)
      EspResponseLoading::Loader
    elsif data_type == 'school_location'
      SchoolLocationLoading::Loader
    else
      EspResponseLoading::Loader
    end
      end
  end
end