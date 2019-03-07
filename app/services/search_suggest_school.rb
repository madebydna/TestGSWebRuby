class SearchSuggestSchool < SearchSuggester
  include UrlHelper

  def get_results(solr_options)
    Search::SolrAutosuggestQuery.new((solr_options[:query])).search
  end

  def process_result(school_search_result)
    return nil unless school_search_result[:type] == 'school'
    school_state_name = States.abbreviation_hash[school_search_result[:state].downcase]
    {
        :state => school_search_result[:state].upcase,
        :school_name => school_search_result[:school],
        :id => school_search_result[:url].scan(/\d+/).first,
        :city_name => school_search_result[:city],
        :url => URI.encode(school_search_result[:url])
    }
  end

  def default_sort
    'sortable_name asc'
  end
end