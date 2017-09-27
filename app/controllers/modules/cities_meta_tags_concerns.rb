module CitiesMetaTagsConcerns
  def cities_show_title
    return "View The Best Schools in #{@city.titleize}, #{@state[:short].upcase} | School Ratings for Public & Private" if %w(pa nj co in).include?(@state[:short].downcase)
    "#{@city.titleize} Schools - #{@city.titleize} #{@state[:long].titleize} School Ratings - Public and Private"
  end

  def cities_show_description
    "Find top-rated #{@city.titleize} schools, read recent parent reviews, and browse private and public schools by grade level in #{@city.titleize}, #{@state[:long].titleize} (#{@state[:short].upcase})."
  end

  def cities_show_keywords
    "#{@city} Schools, #{@city} #{@state[:short].upcase} Schools, #{@city} Public Schools, #{@city} School Ratings, Best #{@city} Schools, #{@city} #{@state[:long]} Schools, #{@city} Private Schools"
  end

  def cities_enrollment_title
    "#{@city.titleize} School Enrollment Information"
  end

  def cities_enrollment_description
    "Practical information including rules, deadlines and tips, for enrolling your child in #{@city.titleize} schools"
  end

  def cities_enrollment_keywords
    "#{@city} school enrollment, #{@city} school enrollment information, #{@city} school enrollment info, #{@city} school enrollment process, #{@city} school enrollment deadlines"
  end

  def cities_community_title
    "The #{@city.titleize} education community"
  end

  def cities_community_description
    "Key local and state organizations that make up the #{@city.titleize} education system"
  end

  def cities_community_keywords
    "#{@city} education system, #{@city} education community, #{@city} education partnerships"
  end

  def cities_events_title
    "Education Events in #{@city.titleize}, #{@state[:short].upcase}"
  end

  def cities_events_description
    "Key dates and events to mark on your calendar"
  end

  def cities_events_keywords
    "#{@city} school system events, #{@city} Public Schools events, #{@city} school system dates, #{@city} Public Schools dates, #{@city} school system calendar, #{@city} Public Schools calendar"
  end

  def cities_choosing_schools_title
    "Choosing a school in #{@city.titleize}, #{@state[:short].upcase}"
  end

  def cities_choosing_schools_description
    "Five simple steps to help parents choose a school in #{@city.titleize}"
  end

  def cities_choosing_schools_keywords
    "Choose a #{@city} school, Choosing #{@city} schools, school choice #{@city}, #{@city} school choice tips, #{@city} school choice steps"
  end

  def cities_programs_title
    "#{@city.gs_capitalize_words} programs"
  end

  def cities_programs_keywords
    "#{@city} programs, child care"
  end

  def cities_programs_description
    "Resources and providers of programs in #{@city.gs_capitalize_words}"
  end

  end
