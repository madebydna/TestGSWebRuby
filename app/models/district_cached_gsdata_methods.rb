module DistrictCachedGsdataMethods
  def gsdata
    cache_data['gsdata'] || {}
  end
end
