class SchoolProfileMetaTags
  attr_reader :school

  def initialize(school)
    @school = school
  end

  def title
    return_title_str = ''
    return_title_str << @school.name + ' - '
    if @school.state.downcase == 'dc'
      return_title_str << 'Washington, DC'
    else
      return_title_str << @school.city + ', ' + @school.state_name.capitalize + ' - ' + @school.state
    end
    return_title_str << ' | GreatSchools'
  end

  def description
    return_description_str = ''
    return_description_str << @school.name
    if @school.preschool?
      if @school.state.downcase == 'dc'
        location_string = 'Washington, DC'
      else
        location_string = "#{@school.city}, #{@school.state_name.capitalize} (#{@school.state})"
      end
      return_description_str << ' in ' + location_string
      return_description_str << '. Read parent reviews and get the scoop on the school environment, teachers,'
      return_description_str << ' students, programs and services available from this preschool.'
    else
      if @school.state.downcase == 'dc'
        location_string = 'Washington, DC'
      else
        location_string = "#{@school.city}, #{@school.state_name.capitalize} - #{@school.state}"
      end
      return_description_str << ' located in ' + location_string
      return_description_str << '. Find ' +  @school.name + ' test scores, student-teacher ratio, parent reviews and teacher stats.'
    end
    return_description_str
  end

  def keywords
    name = @school.name.clone
    return_keywords_str  =''
    return_keywords_str << name
    return_keywords_str << ', ' + name + ' ' + @school.city
    return_keywords_str << ', ' + name + ' ' + @school.city + ' ' + @school.state_name.capitalize
    return_keywords_str << ', ' + name + ' ' + @school.city + ' ' + @school.state
    return_keywords_str << ', ' + name + ' ' + @school.state_name.capitalize
    return_keywords_str << ', ' + name + ' overview'
    return_keywords_str
  end
end