class SchoolSearchService
  @@solr = Solr.new

  KEYS_TO_DELETE = ['contentKey', 'document_type', 'schooldistrict_autosuggest', 'autosuggest', 'name_ordered', 'citykeyword']
  DEFAULT_BROWSE_OPTIONS = {sort: 'overall_gs_rating desc', rows: 25, query: '*', fq: ['+document_type:school']}
  DEFAULT_BY_LOCATION_OPTIONS = {sort: 'distance asc', rows: 25, fq: ['+document_type:school'], qt: 'school-search'}
  DEFAULT_BY_NAME_OPTIONS = {rows: 25, fq: ['+document_type:school'], qt: 'school-search'}
  PARAMETER_TO_SOLR_MAPPING = {
      number_of_results: :rows,
      offset: :start
  }
  SORT_VALUE_MAP = {
      rating_asc: 'sorted_gs_rating_asc asc',
      rating_desc: 'overall_gs_rating desc',
      distance_asc: 'distance asc', # todo not relevant for browse
      distance_desc: 'distance desc', # todo not relevant for browse
      name_asc: 'school_name asc',
      name_desc: 'school_name desc',
      fit_asc: 'overall_gs_rating desc',
      fit_desc: 'overall_gs_rating desc'
  }

  # :city, :state required. Defaults to sorting by gs rating descending, and 25 results per page.
  def self.city_browse(options_param = {})
    raise ArgumentError, 'State is required' unless options_param[:state].presence
    raise ArgumentError, 'State should be a two-letter abbreviation' unless options_param[:state].length == 2
    raise ArgumentError, 'City is required' unless options_param[:city].presence
    options = options_param.deep_dup
    rename_keys(options, PARAMETER_TO_SOLR_MAPPING)
    remap_sort(options)
    filters = extract_filters(options)
    filters << "+citykeyword:\"#{options[:city].downcase}\""
    filters << "+school_database_state:\"#{options[:state].downcase}\""
    options.delete :city
    options.delete :state
    param_options = DEFAULT_BROWSE_OPTIONS.merge(options)
    param_options[:fq] = DEFAULT_BROWSE_OPTIONS[:fq].clone
    filters.each {|filter| param_options[:fq] << filter}

    parse_school_results(get_results param_options)
  end

  # :district_id, :state required. Defaults to sorting by gs rating descending, and 25 results per page.
  def self.district_browse(options_param = {})
    raise ArgumentError, 'State is required' unless options_param[:state].presence
    raise ArgumentError, 'State should be a two-letter abbreviation' unless options_param[:state].length == 2
    raise ArgumentError, 'District id is required' unless options_param[:district_id].presence
    options = options_param.deep_dup
    rename_keys(options, PARAMETER_TO_SOLR_MAPPING)
    remap_sort(options)
    filters = extract_filters(options)
    filters << "+school_district_id:\"#{options[:district_id]}\""
    filters << "+school_database_state:\"#{options[:state].downcase}\""
    options.delete :district_id
    options.delete :state
    param_options = DEFAULT_BROWSE_OPTIONS.merge(options)
    param_options[:fq] = DEFAULT_BROWSE_OPTIONS[:fq].clone
    filters.each {|filter| param_options[:fq] << filter}

    parse_school_results(get_results param_options)

  end

  def self.by_location(options_param = {})
    raise ArgumentError, 'Latitude is required' unless options_param[:lat].presence
    raise ArgumentError, 'Longitude is required' unless options_param[:lon].presence
    options = options_param.deep_dup
    rename_keys(options, PARAMETER_TO_SOLR_MAPPING)
    remap_sort(options)
    filters = extract_filters(options)
    filters << "+school_database_state:\"#{options[:state].downcase}\"" if options[:state]
    options.delete :city
    options.delete :state
    query = extract_by_location options
    param_options = DEFAULT_BY_LOCATION_OPTIONS.merge(options)
    param_options[:fq] = DEFAULT_BY_LOCATION_OPTIONS[:fq].clone
    filters.each {|filter| param_options[:fq] << filter}
    param_options[:query] = query
    parse_school_results(get_results param_options)
  end

  def self.by_name(options_param = {})
    raise ArgumentError, 'Query is required' unless options_param[:query].presence
    raise ArgumentError, 'Query is required' if options_param[:query] =~ /^[\p{Punct}\s]*$/
    options = options_param.deep_dup
    rename_keys(options, PARAMETER_TO_SOLR_MAPPING)
    remap_sort(options)
    filters = extract_filters(options)
    filters << "+school_database_state:\"#{options[:state].downcase}\"" if options[:state]
    options.delete :state
    param_options = DEFAULT_BY_NAME_OPTIONS.merge(options)
    param_options[:fq] = DEFAULT_BY_NAME_OPTIONS[:fq].clone
    param_options[:query] = Solr.prepare_query_string param_options[:query]
    param_options[:query] = Solr.require_non_optional_words param_options[:query]
    filters.each {|filter| param_options[:fq] << filter}
    parse_school_results(get_results param_options)
  end

  protected

  def self.parse_school_document(school_search_result)
    school_search_result.entries.each do |key, value|
      school_search_result[key[7..-1]] = value if key.start_with? 'school_' # strip the preceding 'school_' from keys
    end
    school_search_result.delete_if { |key| key.start_with?('school_') || KEYS_TO_DELETE.include?(key) }
    school_search_result['zipcode'] = school_search_result['zip']
    school_search_result['level'] = school_search_result['grades']
    school_search_result['enrollment'] = school_search_result['size'] if school_search_result.include? 'size'
    school_search_result['state'] = get_state_abbreviation(school_search_result)
    school_search_result['state_name'] = States.state_name(school_search_result['state'])
    school_search_result['school_media_first_hash'] = ((photo = school_search_result['small_size_photos'].presence) ? photo[0].match(/\/(\w*)-/)[1] : nil)
    add_level_codes(school_search_result, school_search_result['grade_level'])
    # convert KM to miles
    school_search_result['distance'] = school_search_result['distance'] / 1.6 if school_search_result['distance']
    SchoolSearchResult.new school_search_result
  end

  def self.parse_school_results(solr_results)
    normalized_results = []
    solr_results['response']['docs'].each do |school_search_result|
      normalized_results << parse_school_document(school_search_result)
    end
    {
        num_found: solr_results['response']['numFound'],
        start: solr_results['response']['start'],
        results: normalized_results
    }
  end

  def self.get_state_abbreviation(hash)
    if hash.include? 'database_state'
      return hash['database_state'].select {|v| v.length == 2 && States.abbreviation_hash.include?(v)}[0]
    end
    return nil
  end

  def self.add_level_codes(hash, grade_level)
    level_codes = []
    if grade_level
      level_codes << 'p' if grade_level.include? 'p'
      level_codes << 'e' if grade_level.include? 'e'
      level_codes << 'm' if grade_level.include? 'm'
      level_codes << 'h' if grade_level.include? 'h'
    end
    hash['level_code'] = (level_codes.join ',') || ''
    hash['level_codes'] = level_codes
  end

  def self.get_results(options)
    @@solr.get_search_results options
  end

  def self.rename_keys(hash, key_map)
    key_map.each do |k, v|
      hash[v] = hash[k]
      hash.delete k
    end
  end

  def self.remap_value(hash, key, value_map)
    hash[key] = value_map[hash[key]] if hash.include? key
  end

  def self.remap_sort(hash)
    remap_value(hash, :sort, SORT_VALUE_MAP)
  end

  def self.extract_filters(hash)
    filter_arr = []
    if hash.include? :filters
      filters = hash[:filters]
      if filters.include?(:school_type) && filters[:school_type].size > 0
        school_types = filters[:school_type].collect {|e| e if [:public, :charter, :private].include? e}
        filter_arr << "+school_type:(#{school_types.compact.join(' ')})" if school_types.compact.size > 0
      end
      if filters.include?(:level_code) && filters[:level_code].size > 0
        level_codes = filters[:level_code].collect { |e| e[0] if [:preschool, :elementary, :middle, :high].include? e}
        filter_arr << "+school_grade_level:(#{level_codes.compact.join(' ')})" if level_codes.compact.size > 0
      end
      if filters.include?(:grades) && filters[:grades].size > 0
        numeric_grade_array = %w(1 2 3 4 5 6 7 8 9 10 11 12)
        normalized_grades = filters[:grades].collect do |e|
          if :grade_p == e
            'PK'
          elsif :grade_k == e
            'KG'
          elsif numeric_grade_array.include? e[6..-1]
            e[6..-1]
          end
        end
        filter_arr << "+grades:(#{normalized_grades.compact.join(' ')})" if normalized_grades.compact.size > 0
      end
      hash.delete :filters
    end
    filter_arr
  end

  def self.extract_by_location(hash)
    query = ''
    if hash.include?(:lat) && hash.include?(:lon)
      radius = hash[:radius] || 5.0
      radius_in_km = radius.to_f * 1.6 # convert to KM
      query = "{!spatial circles=#{hash[:lat]},#{hash[:lon]},#{radius_in_km}}"
    end
    hash.delete :lat
    hash.delete :lon
    hash.delete :radius
    query
  end
end
