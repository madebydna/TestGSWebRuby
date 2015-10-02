module MetaTagsHelper
  def cities_show_title
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

  def state_long_name_with_caps
    state_name = @state[:long].gs_capitalize_words;
    if @state[:short] == 'dc'
      state_name = "Washington DC";
    end
    state_name
  end

  def states_show_title
    "#{state_long_name_with_caps} Schools - #{state_long_name_with_caps} State School Ratings - Public and Private"
  end

  def states_show_description
    "#{state_long_name_with_caps} school information: Test scores, school parent reviews and more. Plus, get expert advice to help find the right school for your child."
  end

  def states_show_keywords
    [
      "#{state_long_name_with_caps} Schools",
      "#{state_long_name_with_caps} Public Schools",
      "#{state_long_name_with_caps} School Ratings",
      "Best #{state_long_name_with_caps} Schools",
      "#{@state[:short].upcase} Schools",
      "#{@state[:short].upcase} Public Schools",
      "#{@state[:short].upcase} School Ratings",
      "Best #{@state[:short].upcase} Schools",
      "Private Schools In #{state_long_name_with_caps}"
    ]
  end

  def cities_programs_title
    "#{@city.gs_capitalize_words} after school and summer programs"
  end

  def cities_programs_keywords
    "#{@city} after school programs, #{@city} summer programs, summer learning, child care"
  end

  def cities_programs_description
    "Resources and providers of after school and summer programs in #{@city.gs_capitalize_words}"
  end

  def states_community_title
    "#{@state[:long].titleize} Education Community"
  end

  def states_community_description
    "Key local and state organizations that make up the #{@state[:long].titleize} education system"
  end

  def states_community_keywords
    "#{@state[:long].titleize} education system, #{@state[:long].titleize} education community, #{@state[:long].titleize} education partnerships"
  end

  def search_params_for_meta_tags
    school_type = school_type_param_for_meta_tags
    level_code = level_code_param_for_meta_tags
    page = page_param_for_meta_tags

    return school_type, level_code, page
  end

  def school_type_param_for_meta_tags
    st_array = ['public', 'private', 'charter', nil]
    text_map = {
        charter: 'Public Charter ',
        public: 'Public ',
        private: 'Private '
    }.stringify_keys

    value = st_array.each { |st| break st if [*@params_hash['st']].include?(st)}
    value = nil unless st_array.include?(value)
    text = text_map[value] if [*@params_hash['st']].count == 1
    param = "&st=#{value}" if value.present?

    Struct.new(:param, :text).new(param, text)
  end

  def level_code_param_for_meta_tags
    lc_array = ['e', 'm', 'h', 'p', nil]
    text_map = {
        e: 'Elementary ',
        m: 'Middle ',
        h: 'High ',
        p: nil
    }.stringify_keys

    value = lc_array.each { |lc| break lc if [*@params_hash['gradeLevels']].include?(lc)}
    value = nil unless lc_array.include?(value)
    text = text_map[value] if [*@params_hash['gradeLevels']].count == 1
    school = value == 'p' ? 'Preschools ' : 'Schools '
    param = "&gradeLevels=#{value}" if value.present?

    Struct.new(:param, :text, :school).new(param, text, school)
  end

  def page_param_for_meta_tags
    current_page = @params_hash['page'].present? ? [*@params_hash['page']].first.to_i : 1
    prev_page = prev_page_for_meta_tags(current_page)
    next_page = next_page_for_meta_tags(current_page)
    current_page = current_page == 1 ? nil : "$page=#{current_page}"

    Struct.new(:current, :prev, :next).new(current_page, prev_page, next_page)
  end

  def next_page_for_meta_tags(current_page)
    current_page < @max_number_of_pages ? "&page=#{current_page + 1}" : nil
  end

  def prev_page_for_meta_tags(current_page)
    if current_page == 2
      ""
    elsif current_page > 2 && current_page <= @max_number_of_pages
      "&page=#{current_page - 1}"
    else
      nil
    end
  end

  def canonical_url_without_params(state_name, city_name)
    search_city_browse_url(state_name.gsub(' ', '-'), city_name).downcase[0..-2]
  end

  def search_city_browse_meta_tag_hash
    school_type, level_code, page = search_params_for_meta_tags
    parameters = "#{level_code.param}#{school_type.param}"
    url_without_params = canonical_url_without_params(@state[:long], @city.name) #downcase and cut trailing slash Todo add test for this!!!

    canonical_url = (url = "#{parameters}#{page.current}".presence) ? "#{url_without_params}?#{url[1..-1]}" : url_without_params
    if url_without_params.casecmp(request.url.split('?').first) == 0
      prev_url = (url = "#{parameters}#{page.prev}".presence) ? "#{url_without_params}?#{url[1..-1]}" : url_without_params unless page.prev.nil?
      next_url = (url = "#{parameters}#{page.next}".presence) ? "#{url_without_params}?#{url[1..-1]}" : url_without_params unless page.next.nil?
    end
    {
      title: "#{@city.name} #{school_type.text}#{level_code.text}#{level_code.school}- #{@city.name}, #{@city.state} | GreatSchools",
      description: "View and map all #{@city.name}, #{@city.state} schools. Plus, compare or save schools",
      canonical: canonical_url,
      prev: (prev_url ||= nil),
      next: (next_url ||= nil)
    }
  end

  def search_district_browse_meta_tag_hash
    school_type, level_code, page = search_params_for_meta_tags
    parameters = "#{level_code.param}"
    url_without_params = canonical_url_without_params(@state[:long], @city.name)

    canonical_url = (url = "#{parameters}#{page.current}".presence) ? "#{url_without_params}?#{url[1..-1]}" : url_without_params
    if url_without_params.casecmp(request.url.split('?').first) == 0
      prev_url = (url = "#{parameters}#{page.prev}".presence) ? "#{url_without_params}?#{url[1..-1]}" : url_without_params unless page.prev.nil?
      next_url = (url = "#{parameters}#{page.next}".presence) ? "#{url_without_params}?#{url[1..-1]}" : url_without_params unless page.next.nil?
    end
    {
      title: "#{school_type.text}#{level_code.text}#{level_code.school}in #{@district.name} - #{@city.name}, #{@city.state} | GreatSchools",
      description: "Ratings and parent reviews for all elementary, middle and high schools in the #{@district.name}, #{@city.state}",
      keywords: "#{@district.name} Schools, #{@city.name} School District, #{@city.name} #{@state[:long]} School District, School District #{@city.name}, #{@district.name} Public Schools, #{@district.name} Charter Schools",
      canonical: (canonical_url),
      prev: (prev_url ||= nil),
      next: (next_url ||= nil)
    }
  end

  def search_by_location_meta_tag_hash
    where_clause = 'state=? and name = ? '
    # Add collation since we can get UTF-8 chars from the web
    where_clause << "COLLATE 'utf8_general_ci' " if @params_hash['city'].present?
    where_clause << 'and active=1'
    if city = City.where(where_clause, @state[:short], @params_hash['city']).first
      school_type, level_code, page = search_params_for_meta_tags
      parameters = "#{level_code.param}#{school_type.param}"
      url_without_params = canonical_url_without_params(@state[:long], city.name)

      canonical_url = (url = "#{parameters}#{page.current}".presence) ? "#{url_without_params}?#{url[1..-1]}" : url_without_params
    end
    {
        title: 'GreatSchools.org Search',
        canonical: (canonical_url ||= state_url(@state[:long].gsub(' ', '-'))).downcase
    }
  end

  def search_by_name_meta_tag_hash
    city = City.where("state=? and name = ? COLLATE 'utf8_general_ci' and active=1", state_abbreviation, @params_hash['q']).first
    if city
      school_type, level_code, page = search_params_for_meta_tags
      parameters = "#{level_code.param}#{school_type.param}"
      url_without_params = canonical_url_without_params(@state[:long], city.name)

      canonical_url = (url = "#{parameters}#{page.current}".presence) ? "#{url_without_params}?#{url[1..-1]}" : url_without_params
    elsif @state.is_a?(Hash) && @state[:long]
      canonical_url ||= state_url(@state[:long].gsub(' ', '-'))
    else
      canonical_url = home_url
    end
    {
        title: "GreatSchools.org Search: #{@params_hash['q']}",
        canonical: canonical_url.downcase
    }
  end
end
