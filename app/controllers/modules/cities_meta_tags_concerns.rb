module CitiesMetaTagsConcerns
  def cities_show_title
    state_text = "#{@city.titleize}, #{@state[:short].upcase} "
    additional_city_text = @state[:short].downcase == 'dc' ? ', DC' : ''
    "Best #{@city.titleize}#{additional_city_text} Schools | #{state_text}School Ratings | Best Schools"
  end

  def cities_show_description
    state_text = @state[:short].downcase == 'dc' ? "#{@state[:short].upcase}" : "#{(@state[:long]).titleize}"
    "Best #{@city.titleize} schools listed by #{@city.titleize} school districts. Browse "\
    "best elementary, middle, and high schools private and public schools by grade level "\
      "in #{@city.titleize}, #{state_text} (#{(@state[:short]).upcase})."
  end

  def cities_enrollment_title
    "#{@city.titleize} School Enrollment Information"
  end

  def cities_enrollment_description
    "Practical information including rules, deadlines and tips, for enrolling your child in #{@city.titleize} schools"
  end

  def cities_community_title
    "The #{@city.titleize} education community"
  end

  def cities_community_description
    "Key local and state organizations that make up the #{@city.titleize} education system"
  end

  def cities_events_title
    "Education Events in #{@city.titleize}, #{@state[:short].upcase}"
  end

  def cities_events_description
    "Key dates and events to mark on your calendar"
  end

  def cities_choosing_schools_title
    "Choosing a school in #{@city.titleize}, #{@state[:short].upcase}"
  end

  def cities_choosing_schools_description
    "Five simple steps to help parents choose a school in #{@city.titleize}"
  end

  def cities_programs_title
    "#{@city.gs_capitalize_words} programs"
  end

  def cities_programs_description
    "Resources and providers of programs in #{@city.gs_capitalize_words}"
  end

end
