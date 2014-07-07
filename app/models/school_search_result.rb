class SchoolSearchResult
  include ActionView::Helpers::AssetTagHelper

  attr_accessor :fit_score, :fit_score_filters, :on_page, :overall_gs_rating
  # Map alternate forms (e.g. legacy Java URL parameters) to solr fields when they do not match
  SOFT_FILTER_MAP = {
      beforeAfterCare: 'before_after_care'
  }

  def initialize(hash)
    @fit_score = 0
    @fit_score_filters = {}
    @attributes = hash
    @attributes.each do |k,v|
      define_singleton_method k do v end
    end
  end

  def preschool?
    (respond_to?('level_code') && level_code == 'p')
  end

  # Increments fit score for each matching key/value pair from params
  def calculate_fit_score(params)
    @fit_score = 0
    params.each do |key, value|
      if value.instance_of?(Array)
        value.each do |v|
          @fit_score += 1 if matches_soft_filter?(key, v)
        end
      else
        @fit_score += 1 if matches_soft_filter?(key, value)
      end
    end
  end

  protected

  def matches_soft_filter?(param, value)
    filter = SOFT_FILTER_MAP[param.to_sym].presence || param
    if filter && respond_to?(filter) && send(filter).include?(value)
      @fit_score_filters.merge!(value => true)
      true
    else
      @fit_score_filters.merge!(value => false)
      false
    end
  end
end
