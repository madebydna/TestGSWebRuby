class SearchSuggestDistrict < SearchSuggester
  include UrlHelper

  def get_results(solr_options)
    Solr.new.district_name_suggest(solr_options)
  end

  def process_result(district_search_result)
    output_district = {}
    district_state = district_search_result['state'].upcase
    district_state_name = States.abbreviation_hash[district_search_result['state'].downcase]
    output_district[:district_name] = district_search_result['district_sortable_name']
    output_district[:sort_order] = district_search_result['district_number_of_schools']
    url = gs_legacy_url_city_district_browse_encode("/#{district_state_name}/#{district_search_result['city'].downcase}/#{district_search_result['district_sortable_name'].downcase}/schools")
    output_district[:url] = URI.encode(url)
    output_district[:state] = district_state

    output_district
  end

  def default_sort
    'district_sortable_name asc,district_number_of_schools desc'
  end
end