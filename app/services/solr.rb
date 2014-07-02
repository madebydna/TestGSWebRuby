class Solr

  LUCENE_SPECIAL_CHARACTERS = %w|\\ + - ! ( ) { } [ ] ^ " ~ * ? :|
  OPTIONAL_TERMS = %w|n s e w ave avenu avenue care charter city citi county counti dai day district east ed elementary elementry elementari fort ft grade height heights high hill ht hts isd intermediate intermediat junior k kindergarten magnet middle middl montessori north nurseri nursery point port pr pre prek pre-k pre k pre-kindergarten preschool primary primar pt school schools road senior south street west and or of|

  def initialize(options = {})
    if options[:state_short].present? && options[:collection_id].present?
      @state_short, @collection_id = options[:state_short], options[:collection_id]
      @connection = RSolr.connect(url: ENV_GLOBAL['solr.ro.server.url'])
    else
      @connection = RSolr.connect(url: ENV_GLOBAL['solr.ro.server.url'])
    end
  end

  def school_name_suggest(options)
    params = parse_params(options)
    params[:fq] << '+document_type:school'
    query = options[:query]
    query.gsub! ' ', '\ '
    params[:q] = "+school_name_untokenized:#{query}*"

    @connection.get 'select/', params: params
  end

  def city_name_suggest(options)
    params = parse_city_params(options)
    params[:fq] << '+document_type:city'
    query = options[:query]
    query.gsub! ' ', '\ '
    params[:q] = "+city_name_untokenized:#{query}*"

    @connection.get 'select/', params: params
  end

  def district_name_suggest(options)
    params = parse_district_params(options)
    params[:fq] << '+document_type:district'
    query = options[:query]
    query.gsub! ' ', '\ '
    params[:q] = "+district_name_untokenized:#{query}*"

    @connection.get 'select/', params: params
  end

  def breakdown_results(options)
    cache_key = "breakdown_results-state:#{@state_short}-collection_id:#{@collection_id}-options:#{options.to_s}"
    Rails.cache.fetch(cache_key, expires_in: cache_time, race_condition_ttl: cache_time) do
      begin
        response = @connection.get "select/", params: parse_params_hubs(options)
        results = { count: response['response']['numFound'], path: parse_url_hubs(options) }
      rescue => e
        Rails.logger.error('Reaching the solr server failed:' + e.to_s)
        results = nil
      end
    end
  end

  def get_search_results(params)
    @connection.get "select/", params: parse_params(params)
  end

  # trim, downcase, add spaces after commas, normalize spaces, escape lucene special chars
  def self.prepare_query_string(query_string)
    query_string.strip! # trim
    query_string.downcase! # convert to lower case
    query_string.gsub!(/,/, ', ') # pad commas with spaces
    query_string.gsub!(/\s+/, ' ') # normalize spaces
    # escape lucene special characters
    # Note use block form of gsub to avoid special parsing of the replacement string in the two-arg format
    # In particular "\\+" has special meaning in the two-arg format.
    # See http://stackoverflow.com/questions/7074337/why-does-stringgsub-double-content
    # Also please note that backslash must be escaped FIRST or else you'll be escaping all your previous escapes!
    LUCENE_SPECIAL_CHARACTERS.each {|char| query_string.gsub!(char) {|m| "\\#{m}" } }
    query_string.strip! # trim once more
    query_string
  end

  # Split on space, add a "+" in front of any non-optional word to make it required, join back up on space
  def self.require_non_optional_words(query_string)
    query_string.split(/ /).collect do |token|
      if get_optional_words.include? token.downcase
        "#{token}"
      else
        "+#{token}"
      end
    end.join " "
  end

  def self.get_optional_words
    return OPTIONAL_TERMS
  end

private

  def cache_time
    LocalizedProfiles::Application.config.hub_mapping_cache_time.minutes.from_now
  end

  def parse_base_params(options)
    params = {}
    params[:qt] = options[:qt] || 'standard'
    params[:fq] = options[:fq] || []
    params[:q] = options[:query] if options[:query]
    params[:sort] = options[:sort] if options[:sort]
    params[:rows] = options[:rows] if options[:rows]
    params[:start] = options[:start] if options[:start]
    params[:spellcheck] = options[:spellcheck]?options[:spellcheck]:false

    params
  end

  def parse_params(options)
    params = parse_base_params options
    params[:fq] << "+school_database_state:#{options[:state]}" if options[:state]
    params[:fq] << "+city:(#{options[:city]})" if options[:city] # TODO: This may be incorrect
    params
  end

  def parse_city_params(options)
    params = parse_base_params options
    params[:fq] << "+city_state:#{options[:state]}" if options[:state]
    params
  end

  def parse_district_params(options)
    params = parse_base_params options
    params[:fq] << "+district_state:#{options[:state]}" if options[:state]
    params
  end

  def parse_params_hubs(options)
    params = { qt: 'school-search', fq: ["+school_database_state:#{@state_short}", "+collection_id:\"#{@collection_id}\""] }
    params[:fq] << "+school_grade_level:(#{options[:grade_level]})" if options[:grade_level]
    params[:fq] << "+school_type:(#{options[:type]})" if options[:type]
    params
  end

  def parse_url_hubs(options)
    url = "schools"
    url += "/?gradeLevels=#{options[:grade_level]}" if options[:grade_level]
    types = options[:type].split /OR/
    types.map!(&:strip)
    url += '&st=' + types.join('&st=')
    url
  end
end
