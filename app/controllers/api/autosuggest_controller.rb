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
    Search::SolrAutosuggestQuery.new(q).search
      .group_by { |h| h[:type] }
      .tap do |hash|
        hash['school'] = hash['school']&.take(5)
        hash['city'] = hash['city']&.take(5)
        hash['district'] = hash['district']&.take(5)
      end
  end

  def set_cache_headers_for_suggest
    cache_time = ENV_GLOBAL['search_suggest_cache_time'] || 0
    expires_in cache_time, public: true
  end
end