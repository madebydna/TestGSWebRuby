# frozen_string_literal: true

module PageAnalytics

  SEARCH_TERM = 'search_term'
  SEARCH_TYPE = 'search_type'
  SEARCH_HAS_RESULTS = 'search_has_results'
  PAGE_NAME = 'page_name'
  CITY = 'City'
  STATE = 'State'
  COUNTY = 'county'
  ENV = 'env'
  COMPFILTER = 'compfilter'
  SCHOOL_ID = 'school_id'
  GS_BADGE = 'gs_badge'
  GS_TAGS = 'gs_tags'

  def set_page_analytics_data
    hash = page_analytics_data
    data_layer_gon_hash.merge!(hash)
  end

  # Should be overridden in controller
  def page_analytics_data
    Rails.logger.warn("\e[31m#analytics_props not implemented in #{self.class.name}\e[0m")
    {}
  end

end