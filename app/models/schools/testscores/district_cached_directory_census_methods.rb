module DistrictCachedDirectoryCensusMethods

  def directory_census
    cache_data['directory_census'] || {}
  end

end