class SchoolSearchService
  @@solr = Solr.new

  KEYS_TO_DELETE = ['contentKey', 'document_type', 'schooldistrict_autosuggest', 'autosuggest', 'name_ordered', 'citykeyword']

  # :city, :state required. Defaults to sorting by gs rating descending, and 25 results per page.
  def self.city_browse(options = {})
    raise ArgumentError, 'State is required' unless options.include?(:state)
    raise ArgumentError, 'State should be a two-letter abbreviation' unless options[:state].length == 2
    raise ArgumentError, 'City is required' unless options.include?(:city)
    key_map = {
        number_of_results: :rows,
        offset: :start
    }
    rename_keys(options, key_map)
    remap_sort(options)
    param_options = {:sort => 'overall_gs_rating desc', :rows => 25, :query => '*'}.merge(options)
    solr_results = get_results param_options

    normalized_hash = {
        :num_found => solr_results['response']['numFound'],
        :start => solr_results['response']['start']
    }
    normalized_results = []
    solr_results['response']['docs'].each do |school_search_result|
      normalized_results << parse_school_document(school_search_result)
    end
    normalized_hash[:results] = normalized_results
    normalized_hash
  end

  class SchoolSearchResult
    include ActionView::Helpers::AssetTagHelper

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

  protected

  def self.parse_school_document(school_search_result)
    school_search_result.entries.each do |key, value|
      school_search_result[key[7..-1]] = value if key.start_with? 'school_' # strip the preceding 'school_' from keys
    end
    school_search_result.delete_if { |key| key.start_with?('school_') || KEYS_TO_DELETE.include?(key) }
    school_search_result['zipcode'] = school_search_result['zip']
    school_search_result['enrollment'] = school_search_result['size'] if school_search_result.include? 'size'
    school_search_result['state'] = get_state_abbreviation(school_search_result)
    school_search_result['state_name'] = States.state_name(school_search_result['state'])
    school_search_result['school_media_first_hash'] = ((photo = school_search_result['small_size_photos'].presence) ? photo[0].match(/\/(\w*)-/)[1] : nil)
    add_level_codes(school_search_result, school_search_result['grade_level'])
    SchoolSearchResult.new school_search_result
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
    sort_map = {
        rating_asc: 'overall_gs_rating asc',
        rating_desc: 'overall_gs_rating desc'
    }
    remap_value(hash, :sort, sort_map)
  end
end