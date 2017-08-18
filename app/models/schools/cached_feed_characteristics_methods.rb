module CachedFeedCharacteristicsMethods

  def feed_characteristics
    cache_data['feed_characteristics'] || {}
  end

end