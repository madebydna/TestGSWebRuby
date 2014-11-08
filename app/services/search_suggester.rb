class SearchSuggester
  DEFAULT_COUNT = 20

  def search(options = {})
    solr_options = {}
    solr_options[:state] = options[:state] if options[:state]
    solr_options[:rows] = options[:limit] || DEFAULT_COUNT
    query = Solr.prepare_query_string(options[:query])
    query.gsub! ' ', '\ '
    solr_options[:query] = query

    results = get_results(solr_options)

    response_objects = []
    unless results.empty? or results['response'].empty? or results['response']['docs'].empty?
      results['response']['docs'].each do |search_result|
        response_objects << process_result(search_result)
      end
    end
    response_objects
  end
end