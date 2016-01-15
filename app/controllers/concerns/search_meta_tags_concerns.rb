module SearchMetaTagsConcerns
  extend ActiveSupport::Concern

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
    param = value.present? ? {'st' => value} : {}

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
    param = value.present? ? {'gradeLevels' => value} : {}

    Struct.new(:param, :text, :school).new(param, text, school)
  end

  def page_param_for_meta_tags
    current_page = @params_hash['page'].present? ? [*@params_hash['page']].first.to_i : 1
    if current_page < @max_number_of_pages
      next_page_num = current_page + 1
    else
      next_page_num = nil
    end
    if current_page == 2
      prev_page_num = 1
    elsif current_page > 2 && current_page <= @max_number_of_pages
      prev_page_num = current_page - 1
    else
      prev_page_num = nil
    end
    param = (current_page == 1) ? {} : {'page' => current_page}

    Struct.new(:param, :prev_page_num, :next_page_num).new(param, prev_page_num, next_page_num)
  end

  def canonical_url_without_params(state_name, city_name)
    escaped_params = city_params(state_name, city_name)
    candidate_url = search_city_browse_url(escaped_params[:state], escaped_params[:city])
    candidate_url.index('?') ? candidate_url[0..candidate_url.index('?')-1] : candidate_url
  end

  def prev_url(url_without_params, prev_page_num, params)
    if prev_page_num
      prev_url = url_without_params
      if prev_page_num == 1
        prev_url + hash_to_query_string(params.reject {|k,_| k == 'page'})
      else
        prev_url + hash_to_query_string(params.merge({'page' => prev_page_num}))
      end
    else
      nil
    end
  end

  def next_url(url_without_params, next_page_num, params)
    next_page_num ? (url_without_params + hash_to_query_string(params.merge({'page' => next_page_num}))) : nil
  end

  def search_city_browse_meta_tag_hash
    school_type, level_code, page = search_params_for_meta_tags
    lang = (I18n.locale == I18n.default_locale ? {} : {'lang' => I18n.locale.to_s})
    params = school_type.param.merge(level_code.param).merge(page.param).merge(lang)
    url_without_params = canonical_url_without_params(@state[:long], @city.name)

    canonical_url = url_without_params + hash_to_query_string(params)
    prev_url = prev_url(url_without_params, page.prev_page_num, params)
    next_url = next_url(url_without_params, page.next_page_num, params)
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
    lang = (I18n.locale == I18n.default_locale ? {} : {'lang' => I18n.locale.to_s})
    params = school_type.param.merge(level_code.param).merge(page.param).merge(lang)
    url_without_params = canonical_url_without_params(@state[:long], @city.name)

    canonical_url = url_without_params + hash_to_query_string(params)
    prev_url = prev_url(url_without_params, page.prev_page_num, params)
    next_url = next_url(url_without_params, page.next_page_num, params)
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
      lang = (I18n.locale == I18n.default_locale ? {} : {'lang' => I18n.locale.to_s})
      params = school_type.param.merge(level_code.param).merge(page.param).merge(lang)
      url_without_params = canonical_url_without_params(@state[:long], city.name)

      canonical_url = url_without_params + hash_to_query_string(params)
    else
      canonical_url = state_url(state_params(@state[:long])[:state])
    end
    {
        title: "GreatSchools.org Search#{pagination_text(false)}",
        canonical: canonical_url
    }
  end

  def search_by_name_meta_tag_hash
    city = City.where("state=? and name = ? COLLATE 'utf8_general_ci' and active=1", state_abbreviation, @params_hash['q']).first
    if city
      school_type, level_code, page = search_params_for_meta_tags
      lang = (I18n.locale == I18n.default_locale ? {} : {'lang' => I18n.locale.to_s})
      params = school_type.param.merge(level_code.param).merge(page.param).merge(lang)
      url_without_params = canonical_url_without_params(@state[:long], city.name)

      canonical_url = url_without_params + hash_to_query_string(params)
    elsif @state.is_a?(Hash) && @state[:long]
      canonical_url ||= state_url(state_params(@state[:long])[:state])
    else
      canonical_url = home_url
    end
    {
        title: "GreatSchools.org Search: #{@params_hash['q']}#{pagination_text(false)}",
        canonical: canonical_url
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

  def hash_to_query_string(hash)
    hash.present? ? ('?' + hash.sort.collect {|(k,v)| "#{k}=#{[*v].first}"}.join('&')) : ''
  end
end
