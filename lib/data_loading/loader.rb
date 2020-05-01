class Loader

  attr_accessor :data_type, :updates, :source

  ACTION_DISABLE = 'disable'
  ACTION_BUILD_CACHE = 'build_cache'
  ACTION_NO_CACHE_BUILD = 'no_cache_rebuild'
  ACTION_WRITE_TO_DB = 'write_db'

  GSDATA_DATA_TYPE = %w(test_scores ratings)

  def initialize(data_type, updates, source)
    @data_type = data_type
    @updates = updates
    @source = source
  end

  def self.esp_data_type?(datatype)
    datatype.to_s.downcase == 'osp'
  end

  def self.school_data_type?(data_type)
    OspData::ESP_KEY_TO_SCHOOL_KEY.values.include?(data_type)
  end

  def self.gsdata_data_type?(data_type)
    GSDATA_DATA_TYPE.include?(data_type)
  end

  def self.determine_loading_class(source, data_type)
    if source == 'osp_form'
      if school_data_type?(data_type)
        SchoolLoading::Loader
      else
        EspResponseLoading::Loader
      end
    elsif source != 'osp_form'
      if data_type == 'directory'
        DirectoryLoading::Loader
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
      elsif gsdata_data_type?( data_type )
        GsdataLoading::Loader
      else
        EspResponseLoading::Loader
      end
    end
  end
end
