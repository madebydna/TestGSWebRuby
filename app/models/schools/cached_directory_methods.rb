module CachedDirectoryMethods

  def directory
    cache_data['directory'] || {}
  end

end