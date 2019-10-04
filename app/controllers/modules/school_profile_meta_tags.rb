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
      return_title_str << @school.city + ', ' + @school.state_name.titleize + ' - ' + @school.state
    end
    return_title_str << I18n.t(:title_suffix, scope: 'controllers.school_profile_controller.meta_tags')
  end

  def description
    if @school.preschool?
      location_string = @school.state.downcase == 'dc' ? 'Washington, DC' : "#{@school.city}, #{@school.state_name.titleize} (#{@school.state})"
      I18n.t('preschool_description', scope: 'controllers.school_profile_controller.meta_tags', school_name: @school.name, location_string: location_string)
    else
      location_string = @school.state.downcase == 'dc' ? 'Washington, DC' : "#{@school.city}, #{@school.state_name.titleize} - #{@school.state}"
      I18n.t('description', scope: 'controllers.school_profile_controller.meta_tags', school_name: @school.name, location_string: location_string)
    end
  end
end