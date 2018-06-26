# frozen_string_literal: true

class Api::AutosuggestController < ApplicationController
  include SearchRequestParams

  def show
    return render json: {} unless q.present?
    set_cache_headers_for_suggest
    render json: {
      school: search(SearchSuggestSchool, count: 20),
      city: search(SearchSuggestCity),
      district: search(SearchSuggestDistrict)
    }
  end

  private

  def search(auto_suggest_class, **other)
    auto_suggest_class.new.search(
      count: 10,
      state: state,
      query: q,
      **other
    )
  end

  def set_cache_headers_for_suggest
    cache_time = ENV_GLOBAL['search_suggest_cache_time'] || 0
    expires_in cache_time, public: true
  end

end