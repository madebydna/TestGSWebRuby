module DistrictsMetaTagsConcerns

  def districts_show_title
    city = @city.gs_capitalize_first
    "#{@district.name} in #{city}, #{@state[:short].upcase} | GreatSchools"
  end

  def districts_show_description
    district = @district.name
    "Information to help parents choose the right public school for their children in the #{district}."
  end
end
