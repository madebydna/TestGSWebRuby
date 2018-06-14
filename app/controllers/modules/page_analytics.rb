# frozen_string_literal: true

module PageAnalytics

  SEARCH_TERM = 'search_term'
  SEARCH_TYPE = 'search_type'
  SEARCH_HAS_RESULTS = 'search_has_results'
  LINKED_FROM = 'linked_from'

  def set_page_analytics_data
    hash = {
      LINKED_FROM => read_and_unset_linked_from_cookie
    }
    page_specific_hash = page_analytics_data
    data_layer_gon_hash.merge!(hash.merge(page_specific_hash))
  end

  def read_and_unset_from_cookie
    val = cookies[:_ga_linked_from]
    cookies.delete(:_ga_linked_from)
    return val
  end

  # Should be overridden in controller
  def page_analytics_data
    Rails.logger.warn("\e[31m#analytics_props not implemented in #{self.class.name}\e[0m")
    {}
  end

end