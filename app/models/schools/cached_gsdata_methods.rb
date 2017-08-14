module CachedGsdataMethods

  def gsdata
    cache_data['gsdata'] || {}
  end

  def equity_overview_rating
    gsdata['Equity Rating'].first['school_value']
  end

  def equity_description
    gsdata['description']
  end

  def equity_methodology
    gsdata['methodology']
  end

end