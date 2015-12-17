module SearchMetaTagsConcerns
 #
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
    city_type_level_code_text = "#{@city.name} #{school_type.text}#{level_code.text}#{level_code.school}"
    {
      title: "#{city_type_level_code_text.chop}#{pagination_text}- #{@city.name}, #{@city.state} | GreatSchools",
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
      title: "#{school_type.text}#{level_code.text}#{level_code.school}in #{@district.name}#{pagination_text(false)} - #{@city.name}, #{@city.state} | GreatSchools",
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
        title: "GreatSchools.org Search#{pagination_text(false)}",
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
        title: "GreatSchools.org Search: #{@params_hash['q']}#{pagination_text(false)}",
        canonical: canonical_url.downcase
    }
  end

  def pagination_text(with_space = true)
    if @total_results < 1 || @results_offset > @total_results
      nil
    else
      first = @results_offset + 1
      last = [@results_offset + @page_size, @total_results].min
      with_space ? ", #{first}-#{last} " : ", #{first}-#{last}"
    end
  end
end
