module CachedNearbySchoolsMethods
  def nearby_schools
    cache_data['nearby_schools'] || {}
  end

end