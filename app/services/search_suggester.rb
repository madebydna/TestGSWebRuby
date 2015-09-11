class SearchSuggester
  DEFAULT_COUNT = 20

  def search(options = {})
    solr_options = solr_options(options)

    results = get_results(solr_options)

    response_objects = []
    if results.present? && results['response'].present? & results['response']['docs'].present?
      results['response']['docs'].each do |search_result|
        response_objects << process_result(search_result)
      end
    end
    response_objects
  end

  def solr_options(options = {})
    solr_options = {}
    solr_options[:state] = options[:state] if options[:state]
    solr_options[:rows] = options[:limit] || DEFAULT_COUNT
    sort = sort_map[options[:sort]] || default_sort
    solr_options[:sort] = sort if sort
    query = Solr.prepare_query_string(options[:query])
    query.gsub! ' ', '\ '
    solr_options[:query] = query
    solr_options
  end

  def sort_map
    {}
  end

  def default_sort
    nil
  end
end