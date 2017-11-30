module DistrictCachedDistrictSchoolsSummaryMethods

  def district_schools_summary
    cache_data['district_schools_summary'] || {}
  end

  def school_counts_by_level_code
    district_schools_summary['school counts by level code']
  end

end
