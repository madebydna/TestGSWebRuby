class ZillowDataReader < SchoolProfileDataReader

  def data_for_category(_)
    hash = {}
    hash['region_id'] = ZillowRegionId.by_school(school)
    hash['zillow_formatted_location'] = school.city.downcase.gsub(/ /, '-') + '-'+States.abbreviation(school.state).downcase

    hash
  end

end