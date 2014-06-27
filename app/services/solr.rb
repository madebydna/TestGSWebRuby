class Solr

  def initialize(options = {})
    if options[:state_short].present? && options[:collection_id].present?
      @state_short, @collection_id = options[:state_short], options[:collection_id]
      @connection = RSolr.connect(url: ENV_GLOBAL['solr.ro.server.url'])
    else
      @connection = RSolr.connect(url: ENV_GLOBAL['solr.ro.server.url'])
    end
  end

  def school_search(options)
    @connection.get "select/", params: parse_params(options)
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

  def school_location_autosuggest(options)
    params = parse_params(options)
    params[:facet] = 'true'
    params[:rows] = 0
    params[:spellcheck] = false
    params['facet.field'] = 'school_autosuggest'
    params['facet.limit'] = 150
    params['facet.mincount'] = 1
    params['f.school_autosuggest.facet.prefix'] = options[:query]
    params[:q] = "+school_autosuggest:#{options[:query]}*"
    params[:fq] << "+state:#{options[:state]}" if options[:state]

    @connection.get "select/", params: params
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
