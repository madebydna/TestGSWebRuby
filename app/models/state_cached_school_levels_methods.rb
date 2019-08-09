module StateCachedSchoolLevelsMethods

  def school_levels
    cache_data['school_levels'] || {}
  end

end