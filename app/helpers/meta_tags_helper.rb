module MetaTagsHelper
  def cities_show_title
    "#{@city.titleize} Schools - #{@city.titleize} #{@state[:long].titleize} School Ratings - Public and Private"
  end

  def cities_show_description
    "Find top-rated #{@city.titleize} schools, read recent parent reviews, and browse private and public schools by grade level in #{@city.titleize}, #{@state[:long].titleize} (#{@state[:short]})."
  end

  def cities_show_keywords
    "#{@city} Schools, #{@city} #{@state[:short]} Schools, #{@city} Public Schools, #{@city} School Ratings, Best #{@city} Schools, #{@city} #{@state[:long]} Schools, #{@city} Private Schools"
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
    "Education Events in #{@city.titleize}, #{@state[:short]}"
  end

  def cities_events_description
    "Key dates and events to mark on your calendar"
  end

  def cities_events_keywords
    "#{@city} school system events, #{@city} Public Schools events, #{@city} school system dates, #{@city} Public Schools dates, #{@city} school system calendar, #{@city} Public Schools calendar"
  end

  def cities_choosing_schools_title
    "Choosing a school in #{@city.titleize}, #{@state[:short]}"
  end

  def cities_choosing_schools_description
    "Five simple steps to help parents choose a school in #{@city.titleize}"
  end

  def cities_choosing_schools_keywords
    "Choose a #{@city} school, Choosing #{@city} schools, school choice #{@city}, #{@city} school choice tips, #{@city} school choice steps"
  end

  def states_show_title
    "#{@state[:long].gs_capitalize_words} Schools - #{@state[:long].gs_capitalize_words} State School Ratings - Public and Private"
  end

  def states_show_description
    "#{@state[:long].gs_capitalize_words} school information: Test scores, school parent reviews and more. Plus, get expert advice to help find the right school for your child."
  end

  def states_show_keywords
    [
      "#{@state[:long].gs_capitalize_words} Schools",
      "#{@state[:long].gs_capitalize_words} Public Schools",
      "#{@state[:long].gs_capitalize_words} School Ratings",
      "Best #{@state[:long].gs_capitalize_words} Schools",
      "#{@state[:short]} Schools",
      "#{@state[:short]} Public Schools",
      "#{@state[:short]} School Ratings",
      "Best #{@state[:short]} Schools",
      "Private Schools In #{@state[:long].gs_capitalize_words}"
    ]
  end
end
