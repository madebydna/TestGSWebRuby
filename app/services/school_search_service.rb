class SchoolSearchService
  @@solr = Solr.new

  # City,State required. Defaults to sorting by gs rating descending, and 25 results per page.
  def self.city_browse(state, city, options)
    param_options = {:state => state, :city => city, :sort => 'overall_gs_rating desc', :rows => 25}
    param_options.merge! options
    solr_results = @@solr.get_search_results param_options

    normalized_hash = {}
    normalized_hash[:num_found] = solr_results['response']['numFound']
    normalized_hash[:start] = solr_results['response']['start']
    normalized_results = []
    keys_to_delete = ['contentKey', 'document_type', 'schooldistrict_autosuggest', 'autosuggest', 'name_ordered', 'citykeyword']
    solr_results['response']['docs'].each do |school_search_result|
      school_search_result.entries.each do |key, value|
        school_search_result[key[7..-1]] = value if key.start_with? 'school_' # remove preceding 'school_' from keys
      end
      school_search_result['enrollment'] = school_search_result['size'] if school_search_result.include? 'size'
      school_search_result['state'] = get_state_abbreviation(school_search_result)
      school_search_result['state_name'] = States.state_name(school_search_result['state'])
      school_search_result.delete_if {|key| key.start_with?('school_') || keys_to_delete.include?(key)}
      add_profile_url(school_search_result)
      add_level_codes(school_search_result, school_search_result['grade_level'])
      result_obj = SchoolSearchResult.new school_search_result
      normalized_results << result_obj
    end
    normalized_hash[:results] = normalized_results
    normalized_hash
  end

  class SchoolSearchResult
    def initialize(hash)
      @attributes = hash
      @attributes.each do |k,v|
        define_singleton_method k do v end
      end
    end

    def preschool?
      (respond_to?('level_code') && level_code == 'p')
    end
  end

  private

  def self.get_state_abbreviation(solr_state)
    solr_state['database_state'].select {|v| v.length == 2}[0]
  end

  def self.add_level_codes(hash, grade_level)
    level_codes = []
    level_codes << 'p' if grade_level.include? 'p'
    level_codes << 'e' if grade_level.include? 'e'
    level_codes << 'm' if grade_level.include? 'm'
    level_codes << 'h' if grade_level.include? 'h'
    hash['level_code'] = level_codes.join ','
    hash['level_codes'] = level_codes
  end

  def self.add_profile_url(hash)
    hash['profile_url'] = "/#{hash['state_name']}/#{hash['city'].downcase}/#{hash['id']}-#{hash['name'].downcase}/" #TODO
  end
end