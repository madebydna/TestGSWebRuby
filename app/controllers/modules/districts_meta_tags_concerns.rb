module DistrictsMetaTagsConcerns

  def districts_show_title
    state = @state[:short].upcase
    city = @city.gs_capitalize_first
    district = @district.name
    "#{district} in #{city}, #{state} | GreatSchools"
  end

  def districts_show_description
    district = @district.name
    "Information to help parents choose the right public school for their children in the #{district}."
  end

  def districts_show_keywords
    district = @district.name
    "#{district} Schools, #{district} Public Schools, #{district} School Ratings, Best #{district} Schools"
  end

  end
