class SearchPage < SitePrism::Page

  set_url_matcher /search\/search\.page/

  element :search_results_list_view_link, ".js-search-list-view"
  element :search_results_map_view_link, ".js-search-map-view"

end
