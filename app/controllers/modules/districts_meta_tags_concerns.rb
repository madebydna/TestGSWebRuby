module DistrictsMetaTagsConcerns

  def districts_show_title
    city = @city.gs_capitalize_first
    return "#{@district.name}, #{@state[:long].gs_capitalize_words} School Rankings | Rate #{@district.name} Public Schools | GreatSchools" if %w(ca tx fl ny ga il nc nj vi pa).include?(@state[:short].downcase)
    "#{@district.name} in #{city}, #{@state[:short].upcase} | GreatSchools"
  end

  def districts_show_description
    district = @district.name
    "Information to help parents choose the right public school for their children in the #{district}."
  end
end
