module CachedGsdataMethods

  def gsdata
    cache_data['gsdata'] || {}
  end

end