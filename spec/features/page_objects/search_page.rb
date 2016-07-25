require 'features/page_objects/modules/footer'

class SearchPage < SitePrism::Page
  include Footer

  set_url_matcher /search\/search\.page/

  element :search_results_list_view_link, ".js-search-list-view"
  element :search_results_map_view_link, ".js-search-map-view"

  elements :school_search_results, '.js-schoolSearchResultCompareErrorMessage'

end
