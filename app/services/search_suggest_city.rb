class SearchSuggestCity < SearchSuggester
  include UrlHelper

  def get_results(solr_options)
    Solr.new.city_name_suggest(solr_options)
  end

  def process_result(city_search_result)
    output_city = {}
    city_state = city_search_result['city_state'][0].upcase
    city_state_name = States.abbreviation_hash[city_search_result['city_state'][0].downcase]
    output_city[:city_name] = city_search_result['city_sortable_name']
    output_city[:url] = gs_legacy_url_city_district_browse_encode("/#{city_state_name}/#{city_search_result['city_sortable_name'].downcase}/schools")
    url = gs_legacy_url_city_district_browse_encode("/#{city_state_name}/#{city_search_result['city_sortable_name'].downcase}/schools")
    output_city[:url] = URI.encode(url)
    output_city[:sort_order] = city_search_result['city_number_of_schools']
    output_city[:state] = city_state

    output_city
  end

  def default_sort
    'city_sortable_name asc,city_number_of_schools desc'
  end
end