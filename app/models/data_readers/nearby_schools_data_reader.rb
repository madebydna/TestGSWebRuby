class NearbySchoolsDataReader < SchoolProfileDataReader

  # Note that this is not being used right now. Due to the sidenav currently on
  # the report card and details pages of the profiles, the neaby schools sticky
  # module had to be hardcoded and could not be inserted via the profile config
  # tool per usual. Keeping this here in case we want to use it later.
  def data_for_category(category)
    school.cache_results.nearby_schools['closest_top_then_top_nearby_schools']
  rescue
    []
  end
end
