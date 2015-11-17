class NearbySchoolsDataReader < SchoolProfileDataReader

  def data_for_category(category)
    school.cache_results.nearby_schools[NearbySchoolsCaching::Lists::ClosestSchools::NAME]
  rescue
    []
  end
end
