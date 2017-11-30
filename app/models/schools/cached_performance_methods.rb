module CachedPerformanceMethods
  def performance
    cache_data['performance'] || {}
  end
end