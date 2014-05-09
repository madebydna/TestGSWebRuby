module SeoHelper
  def partner_page_meta_keywords(page_name, acro_name)
    result = ""
    result << page_name << ", "
    result << page_name << " partnership, "

    if acro_name.blank?
      result << page_name << " GreatSchools partnership"
    else
      result << acro_name << " partnership, "
      result << page_name << " GreatSchools partnership, "
      result << acro_name << " GreatSchools partnership"
    end
    result
  end

  def partner_page_description(page_name)
    "GreatSchools has partnered with #{page_name} to help you explore your options and find the right school for your child."
  end

  def state_page_title
    "#{@state[:long]} Schools - #{@state[:long]} State School Ratings - Public and Private"
  end

  def state_page_description
    "#{@state[:long]} school information: Test scores, school parent reviews and more. Plus, get expert advice to help find the right school for your child."
  end

  def state_page_keywords
    [
      "#{@state[:long]}",
      "Schools, #{@state[:long]} Public Schools",
      "#{@state[:long]} School Ratings",
      "Best #{@state[:long]} Schools",
      "#{@state[:short]} Schools",
      "#{@state[:short]} Public Schools",
      "#{@state[:short]} School Ratings",
      "Best #{@state[:short]} Schools",
      "Private Schools in #{@state[:long]}"
    ]
  end
end
