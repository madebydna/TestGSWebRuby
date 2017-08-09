module DistrictCachedDirectoryMethods

  def district_directory
    cache_data['district_directory'] || {}
  end

end