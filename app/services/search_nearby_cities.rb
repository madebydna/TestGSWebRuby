class SearchNearbyCities
  DEFAULT_CITY_COUNT = 8
  NEARBY_CITY_RADIUS = 80.0

  def search(options = {})
    validate_params(options)
    solr_params = {}
    solr_params[:query] = "{!cityspatial circles=#{options[:lat]},#{options[:lon]},#{NEARBY_CITY_RADIUS}}"
    solr_params[:rows] = options[:count] || DEFAULT_CITY_COUNT
    solr_params[:fq] = []
    if options[:exclude_city].presence
      city_keyword = options[:exclude_city].downcase
      city_keyword = Solr.prepare_term(city_keyword)
      solr_params[:fq] << "-city_keyword:#{city_keyword}"
    end
    solr_params[:fq] << '+document_type:city'
    solr_params[:qt] = 'city-search'
    parse_city_results(Solr.new.get_search_results(solr_params))
  end

  def parse_city_results(solr_results)
    normalized_results = []
    solr_results['response']['docs'].each do |city_search_result|
      normalized_results << CitySearchResult.new(city_search_result)
    end
    normalized_results
  end

  def validate_params(options)
    raise ArgumentError, 'Latitude is required' unless options[:lat].presence
    raise ArgumentError, 'Longitude is required' unless options[:lon].presence
  end
end