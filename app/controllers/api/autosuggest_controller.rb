# frozen_string_literal: true

class Api::AutosuggestController < ApplicationController
  include SearchRequestParams

  def show
    return render json: {} unless q.present?
    set_cache_headers_for_suggest
    render json: results
  end

  private

  def results
    grouped_results = Search::SolrAutosuggestQuery.new(q)
                       .search
                       .group_by { |h| h[:type] }
    {}.tap do |hash|
      hash['Schools'] = grouped_results['school']&.take(5)
      hash['Cities'] = grouped_results['city']&.take(5)
      hash['Districts'] = grouped_results['district']&.take(5)
      hash['Zipcodes'] = q.match?(/\d{3}+/) ? grouped_results['zip']&.take(5) : []
    end
  end

  def set_cache_headers_for_suggest
    cache_time = ENV_GLOBAL['search_suggest_cache_time'] || 0
    expires_in cache_time, public: true
  end
end