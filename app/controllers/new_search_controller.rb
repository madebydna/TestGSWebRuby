# frozen_string_literal: true

class NewSearchController < ApplicationController
  include Pagination::PaginatableRequest
  include SearchRequestParams

  layout 'application'
  before_filter :redirect_unless_valid_search_criteria # we need at least a 'q' param or state and city/district

  def search
    gon.search = {
      schools: schools.map { |s| Api::SchoolSerializer.new(s).to_hash },
    }.tap do |props|
      props.merge!(Api::CitySerializer.new(city_object).to_hash) if city_object
      props.merge!(Api::PaginationSummarySerializer.new(paginated_results).to_hash)
      props.merge!(Api::PaginationSerializer.new(paginated_results).to_hash)
    end

    prev_page = prev_page_url(paginated_results)
    next_page = next_page_url(paginated_results)
    set_meta_tags(prev: prev_page) if prev_page
    set_meta_tags(next: next_page) if next_page
  end

  private

  def redirect_unless_valid_search_criteria
    redirect_to(home_path) unless q || (state && (city || district))

    if state && city
      redirect_to(state_path(States.state_path(state))) unless city_object
    elsif state && district
      # TODO: implement. redirect_to(city_path(state, city) unless district_object
    end
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
