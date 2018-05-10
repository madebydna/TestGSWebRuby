# frozen_string_literal: true

class NewSearchController < ApplicationController
  include Pagination::PaginatableRequest
  include SearchRequestParams

  layout 'application'
  before_filter :redirect_unless_city_found

  def search
    gon.search = {
      schools: schools.map { |s| Api::SchoolSerializer.new(s).to_hash },
    }.merge(Api::CitySerializer.new(city_object).to_hash)
     .merge(Api::PaginationSummarySerializer.new(paginated_results).to_hash)
     .merge(Api::PaginationSerializer.new(paginated_results).to_hash)

     prev_page = prev_page_url(paginated_results)
     next_page = next_page_url(paginated_results)

     set_meta_tags(prev: prev_page) if prev_page
     set_meta_tags(next: next_page) if next_page
  end

  private

  def redirect_unless_city_found
    redirect_to(state_path(States.state_path(state))) unless city_object
  end

  def schools
    @_schools ||= begin
      SchoolCacheQuery
        .decorate_schools(
          paginated_results,
          'ratings',
          'characteristics'
        )
    end
  end

  # paginatable school documents
  def paginated_results
    @_paginated_results ||= school_search.search
  end

  def school_search
    @_school_search ||= begin
      if params[:solr7]
        Search::SolrSchoolQuery.new(city: city, state: state, q:q, level_codes: level_codes, entity_types: entity_types, offset: offset, limit: limit)
      else
        Search::LegacySolrSchoolQuery.new(city: city, state: state, q:q, level_codes: level_codes, entity_types: entity_types, offset: offset, limit: limit)
      end
    end
  end

end
