class NearbySchoolsDataReader < SchoolProfileDataReader

  def data_for_category(category)
    school.cache_results.nearby_schools['closest_top_then_top_nearby_schools']
  rescue
    []
  end
end
