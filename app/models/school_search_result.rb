class SchoolSearchResult
  include ActionView::Helpers::AssetTagHelper

  attr_accessor :fit_score, :max_fit_score, :fit_score_map, :on_page, :overall_gs_rating
  # Map alternate forms (e.g. legacy Java URL parameters) to solr fields when they do not match
  SOFT_FILTER_MAP = {
      beforeAfterCare: 'before_after_care'
  }

  def initialize(hash)
    @fit_score = 0
    @max_fit_score = 0
    @fit_score_map = {}
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
    @fit_score_map = {}
    @max_fit_score = 0
    params.each do |key, value|
      @fit_score_map[key] ||= {}
      if value.instance_of?(Array)
        value.each do |v|
          @max_fit_score += 1
          is_match = matches_soft_filter?(key, v)
          @fit_score += 1 if is_match
          @fit_score_map[key][v] = is_match
        end
      else
        @max_fit_score += 1
        is_match = matches_soft_filter?(key, value)
        @fit_score += 1 if is_match
        fit_score_map[key][value] = is_match
      end
    end
  end

  protected

  def matches_soft_filter?(param, value)
    filter = SOFT_FILTER_MAP[param.to_sym].presence || param
    filter && respond_to?(filter) && send(filter).include?(value)
  end
end
