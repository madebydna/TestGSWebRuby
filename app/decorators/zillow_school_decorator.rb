class ZillowSchoolDecorator < Draper::Decorator
  decorates :school

  def region_id
    @region_id ||= ZillowRegionId.by_school(school)
  end

  def zillow_formatted_location
    school.city.downcase.gsub(/ /, '-') + '-'+States.abbreviation(school.state).downcase
  end

end