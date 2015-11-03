class NearbySchoolsDataReader < SchoolProfileDataReader

  def data_for_category(category)
    school.cache_results.nearby_schools
  rescue
    []
  end
end
