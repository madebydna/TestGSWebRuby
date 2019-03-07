class SearchSuggester
  DEFAULT_COUNT = 20

  def search(options = {})
    solr_options = solr_options(options)
    results = get_results(solr_options)

    if results.total > 0
      return results.map { |r| process_result(r) }.compact
    end
  end

  def solr_options(options = {})
    solr_options = {}
    solr_options[:state] = options[:state] if options[:state]
    solr_options[:rows] = options[:limit] || DEFAULT_COUNT
    sort = sort_map[options[:sort]] || default_sort
    solr_options[:sort] = sort if sort
    query = ::Solr::Solr.prepare_query_string(options[:query])
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