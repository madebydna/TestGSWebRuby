module FeedDistrictCachedCharacteristicsMethods

  def feed_district_characteristics
    cache_data['feed_district_characteristics'] || {}
  end

end